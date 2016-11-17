/* ............................................................................

   Programa: Fontes/dctrori.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                     Ultima atualizacao: 11/09/2014
   

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela DCTROR.

   Alteracoes: 30/08/94 - Alterado para nao permitir alteracoes se o associado
                          tem dtelimin (Deborah).

               28/10/94 - Alterado para incluir o indicador de cheque 6 (Odair)

               06/07/95 - No crapchq e crapcht se o incheque = 8 enviar a
                          critica 320 (Odair).

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               06/11/98 - Tratar situacao em prejuizo (Deborah).

               10/11/98 - Logar a alteracao de situacao do titular (Deborah).

               16/08/1999 - Permitir colocar contra-ordem em cheques que ja
                            entraram, para futura devolucao (Deborah).

               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).
                            
               16/07/2003 - Alterar a conta do convenio do BB de fixo para   
                            a variavel aux_lsconta2 ou aux_lsconta3 (Fernando).
                             
               08/09/2004 - Tratar conta integracao (Margarete).
               
               17/11/2004 - Pedir confirmacao de operacao (Evandro).

               01/07/2005 - Alimentado campo cdcooper da tabela crapcor (Diego)
               
               04/10/2005 - Implementado F7 para codigo do historico (Diego).
               
               09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               21/10/2005 - Tratamento da tabela crapfdc (SQLWorks - Andre).
               
               22/10/2005 - Criacao da funcao para conta de integracao
                            (SQLWorks - Andre).
                            
               23/10/2005 - Retirada da variavel tel_nrtalchq dos FORMs f_erros
                            f_label e f_lanctos (SQLWorks - Andre).             

               26/10/2005 - Implementar a chamada da rotina fontes/digbbx.p
                            (Edson).

               23/11/2005 - Alimentar os campo dtmvtolt, cdoperad e hrtransa
                            na tabela crapcor (Edson).
                            
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               13/02/2007 - Incluidos novos campos utilizados na operacao tipo
                            2(contra-ordem), e efetuada alteracao para nova
                            estrutura crapcor (Diego).
                            Alterar consultas com indice crapfdc1 (David).
                            
               01/03/2007 - Alteracao na crapcch para o BANCOOB (Evandro).
               
               19/03/2007 - Buscar o registro crapcor com nro do cheque com
                            digito (Evandro).

               20/03/2007 - Se cooperado tem cheques a liberar, nao deixa ser
                            bloqueado (Elton).

               11/05/2007 - Melhoria no controle da criacao da "crapcch"
                            (Evandro).
                
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.
                          - Incluido parametro "glb_cdcooper" para possibilitar
                            a chamada do programa fontes/zoom_historicos.p.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               20/08/2008 - Tratar praca de compensacao (Magui).

               09/09/2009 - Verificar se cheque esta em desconto (David).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               16/03/2010 - Adaptacao Projeto IF CECRED (Guilherme).
               
               25/03/2010 - Adaptar o <F7> do historico (Gabriel). 
               
               11/02/2011 - Opcao de inclusao de varios registros de cheque 
                            para contra-ordem.
                            Impressao de termo de contra-ordem apos inclusao
                            (GATI - Daniel/Eder)
                            
               28/03/2011 - Acerto na alteracao acima, esta dando message de OK
                            porem todas alteracoes nao estao na mesma transacao
                            e o operador tecla END-ERROR (Guilherme).
                            
               30/03/2011 - Alterado para imprimir carta somente para transacao
                            do tipo 2 "Contra ordem/Aviso" (Adriano).
                            
               11/04/2011 - Alterado para chamar "grava_crapcch" somente na 
                            procedure Efetua_inclusao (Diego).
                            
               08/06/2011 - Adaptacao para uso de BO. (André - DB1)
               
               13/12/2011 - Inclusão de parametro de saída tel_dtvalcor 
                            (André R./Supero)
                            
               18/05/2012 - Alterar Mensagem de Prov. p/ Permanente (Ze).
               
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

DEF VAR aux_dtvalcor AS DATE                                           NO-UNDO.
DEF VAR aux_flprovis AS LOGI INIT FALSE                                NO-UNDO.
DEF VAR aux_flimprim AS LOGI INIT FALSE                                NO-UNDO.
DEF VAR aux_cdagechq AS INTEGER                                        NO-UNDO.
DEF VAR aux_cdageant AS INTEGER                                        NO-UNDO.


DEF QUERY qr-contra FOR tt-contra.

DEF BROWSE br-contra QUERY qr-contra
   DISP tt-contra.cdhistor NO-LABEL FORMAT ">>>>>9"
        tt-contra.cdbanchq NO-LABEL FORMAT ">>>>9"
        tt-contra.cdagechq NO-LABEL FORMAT ">>>>>>"
        tt-contra.nrctachq NO-LABEL FORMAT ">>>>>>,>>>,>>>,>"
        tt-contra.nrinichq NO-LABEL FORMAT "zzz,zzz,z "
        tt-contra.nrfinchq NO-LABEL FORMAT "zzz,zzz,z"
        tt-contra.flprovis NO-LABEL FORMAT "  SIM/  NAO"
   WITH 5 DOWN NO-BOX.
   
FORM br-contra AT 1
     WITH ROW 14 COLUMN 2 FRAME f-browse OVERLAY NO-BOX.
     
FORM " Aguarde... Imprimindo SUSTACAO/CONTRAORDEM! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

DEF QUERY q_custdesc FOR tt-custdesc.

DEF BROWSE b_custdesc QUERY q_custdesc
    DISP tt-custdesc.flgselec FORMAT "*/"         NO-LABEL
         tt-custdesc.nrdconta FORMAT "zzzz,zzz,9" COLUMN-LABEL "Favorecido"
         tt-custdesc.nmprimtl FORMAT "X(46)"      NO-LABEL             
         tt-custdesc.nrcheque /*FORMAT "zzzz,zzz,z"*/ COLUMN-LABEL "Cheque"
    WITH 6 DOWN NO-BOX CENTERED WIDTH 72.

FORM b_custdesc HELP "Tecle ENTER para selecionar, F1 para continuar e END para sair"
     SKIP
     "-----------------------------------" AT 3
     SPACE(0)
     "-----------------------------------"
     tt-custdesc.flgcusto AT 03 LABEL "Cheque em Custodia" FORMAT "SIM/NAO" 
     tt-custdesc.dtliber1 AT 47 LABEL "Liberacao para"     FORMAT "99/99/9999"
     SKIP
     tt-custdesc.cdpesqu1 AT 10 LABEL "Digitado em"        FORMAT "X(50)"
     SKIP(1)
     tt-custdesc.flgdesco AT 03 LABEL "Cheque em Desconto" FORMAT "SIM/NAO" 
     tt-custdesc.dtliber2 AT 47 LABEL "Liberacao para"     FORMAT "99/99/9999"
     SKIP
     tt-custdesc.cdpesqu2 AT 10 LABEL "Digitado em"        FORMAT "X(50)"
     WITH ROW 5 COL 1 WIDTH 76 OVERLAY CENTERED SIDE-LABELS 
        TITLE " CHEQUES EM CUSTODIA/DESCONTO " FRAME f_custdesc.


ON  ENTRY, VALUE-CHANGED OF b_custdesc DO:
    IF  AVAIL tt-custdesc  THEN
        DO:
            DISPLAY tt-custdesc.flgcusto
                    tt-custdesc.dtliber1              
                    tt-custdesc.cdpesqu1            
                    tt-custdesc.flgdesco
                    tt-custdesc.dtliber2            
                    tt-custdesc.cdpesqu2
                    WITH FRAME f_custdesc.
        END.    
END.

ON  "ENTER" OF b_custdesc DO:

    IF  AVAIL tt-custdesc  THEN
        DO:
            IF  tt-custdesc.flgselec  THEN
                ASSIGN tt-custdesc.flgselec:SCREEN-VALUE 
                                           IN BROWSE b_custdesc = STRING(FALSE)
                       tt-custdesc.flgselec = FALSE.
            ELSE
                ASSIGN tt-custdesc.flgselec:SCREEN-VALUE 
                                           IN BROWSE b_custdesc = STRING(TRUE)
                       tt-custdesc.flgselec = TRUE.
        END.
END.

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
    
    HIDE FRAME f_prov_i NO-PAUSE.
    
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
                   tel_nrctachq = tt-dctror.nrctachq.
        END.

    
    IF  tel_tptransa = 2 THEN
        DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl tel_dtemscor
                WITH FRAME f_dctror.
    
    IF  tel_tptransa = 1  OR tel_tptransa = 3  THEN
        DO:
            DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl
                     WITH FRAME f_dctror.

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
    
            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Inclusao efetuada com sucesso!".
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

            NEXT-PROMPT tel_cdhistor WITH FRAME f_dctror.

            ASSIGN tel_cdhistor = 0
                   tel_cdbanchq = 0
                   tel_cdagechq = 0
                   tel_nrctachq = 0
                   tel_nrinichq = 0
                   tel_nrfinchq = 0.

            DISPLAY tel_cdhistor tel_cdbanchq tel_cdagechq tel_nrctachq 
                    tel_nrinichq tel_nrfinchq tel_dtvalcor
                    WITH FRAME f_dctror.
         
            SET tel_dtemscor  WITH FRAME f_dctror.
         
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
                               tel_cdbanchq = 0
                               tel_cdagechq = 0
                               tel_nrctachq = 0
                               tel_nrinichq = 0
                               tel_nrfinchq = 0.
    
                        DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl tel_dtemscor
                                tel_cdhistor tel_cdbanchq tel_cdagechq tel_nrctachq 
                                tel_nrinichq tel_nrfinchq tel_dtvalcor
                                WITH FRAME f_dctror.
                        ASSIGN aux_lcontrat = NO.
                    END.
    
                IF  CAN-FIND(FIRST tt-contra) THEN DO:
                    OPEN QUERY qr-contra FOR EACH tt-contra.
                    DISP br-contra WITH FRAME f-browse.
                    ENABLE ALL WITH FRAME f-browse.
                END.
    
                Banco: DO WHILE TRUE:
                                    ASSIGN glb_cdcritic = 0.
                    MESSAGE COLOR NORMAL
                        "F1 - Confirmar inclusao, F4/END - Cancelar inclusao.".
                  
                    UPDATE tel_cdhistor WITH FRAME f_dctror
        
                    EDITING:
        
                        READKEY.
        
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                            DO:
                                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    aux_confirma = "N".
                                    
                                    BELL. 
                                    HIDE MESSAGE NO-PAUSE.
                                    MESSAGE COLOR NORMAL "Deseja abandonar" + 
                                                          " esta inclusão?(S/N)"
                                    UPDATE aux_confirma.
                                   
                                    glb_cdcritic = 0.
                                    LEAVE.
                                END.
                        
                                IF  aux_confirma = "n" THEN
                                    NEXT Banco.
                        
                                IF aux_confirma = "s" THEN 
                                    DO:
                                        CLEAR FRAME f_dctror NO-PAUSE.
                                        UNDO Princ, LEAVE Princ. 
                                    END.
                            END.
                        ELSE
                        IF  LASTKEY     = KEYCODE("F7")    AND
                            FRAME-FIELD = "tel_cdhistor"   THEN
                            DO:
                                RUN fontes/zoom_historicos.p
                                   ( INPUT glb_cdcooper, 
                                     INPUT FALSE,
                                     INPUT 9, 
                                    OUTPUT tel_cdhistor ).
                                         
                                DISPLAY tel_cdhistor WITH FRAME f_dctror.    
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
                                                        &VAR-GERAL=SIM
                                                        &NOME-FRAME="f_dctror"
                                                        &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.
                            END.
                    END.  /*  Fim do EDITING  */ 
                      
                    MESSAGE COLOR NORMAL
                        "F1 - Confirmar inclusao, F4/END - Cancelar inclusao.".
                  
                    UPDATE tel_cdbanchq WITH FRAME f_dctror
        
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
                                                        &NOME-FRAME="f_dctror"
                                                        &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.
                            END.
                    END. /*  Fim do EDITING  */ 
        
                    DISPLAY tel_cdagechq WITH FRAME f_dctror.

                    /* Verificar se é uma conta migrada da concredi 
                       ou credimilsul*/
                    FIND FIRST craptco 
                        WHERE craptco.cdcooper = glb_cdcooper AND
                              craptco.nrdconta = tel_nrdconta AND
                             (craptco.cdcopant = 4 OR 
                              craptco.cdcopant = 15 ) NO-LOCK NO-ERROR.

                    /* Se localizar a conta, então deve permitir
                       informar a agencia*/
                    IF  AVAIL(craptco) THEN 
                    DO:
                        MESSAGE COLOR NORMAL
                            "F1 - Confirmar inclusao, F4/END - " 
                            + "Cancelar inclusao.".
                        /* Guardar valor atual para verificar se foi alterado*/
                        ASSIGN aux_cdagechq = tel_cdagechq.

                        UPDATE tel_cdagechq WITH FRAME f_dctror
            
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
                                    
                                    /* somente necessario validar se 
                                       foi alterado*/
                                    IF aux_cdagechq <> tel_cdagechq THEN 
                                    DO:
                                        /*validar agencia na cooper antiga*/
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
                                          MESSAGE "Agencia do cheque invalida, "
                                                  + "para este banco "
                                                  + "são permitidas agencias " 
                                                  + STRING(aux_cdageant) + " e " 
                                                  + STRING(aux_cdagechq).
                                        {sistema/generico/includes/foco_campo.i
                                                  &NOME-FRAME="f_dctror"
                                                  &NOME-CAMPO=aux_nmdcampo }
                                       END.            
                                    END. /*Fim aux_cdagechq <> tel_cdagechq*/              

                                END.
                        END. /*  Fim do EDITING  */ 
                    END. /* Fim avail craptco*/
                    
                    MESSAGE COLOR NORMAL
                        "F1 - Confirmar inclusao, F4/END - Cancelar inclusao.".
                   
                    SET tel_nrctachq tel_nrinichq tel_nrfinchq WITH FRAME f_dctror
                    
                    EDITING:
        
                        READKEY.
                      
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            NEXT Banco.
                      
                        IF  LASTKEY = KEYCODE("F1")   THEN 
                            DO:
                                HIDE MESSAGE NO-PAUSE.
                      
                                IF  NOT CAN-FIND(FIRST tt-contra)   THEN 
                                    DO:
                                        MESSAGE "Nenhuma Contra Ordem foi Informada!".
                                    END.
                                ELSE 
                                    DO:
                                        

                                        ASSIGN glb_cdcritic = 78.
                                        RUN fontes/critic.p.
                                        BELL.

                                        ASSIGN aux_confirma = "N".
                                        MESSAGE COLOR NORMAL glb_dscritic 
                                                UPDATE aux_confirma.
                                        ASSIGN glb_cdcritic = 0.

                                        IF  aux_confirma = "S"   THEN 
                                          DO:
                                             LEAVE Editar.
                                        END. /* FIM do 1º IF  aux_confirma = "S" */

                                END.
                            END.
                        ELSE 
                            APPLY LASTKEY.
        
                        IF  GO-PENDING  THEN
                            DO:
                                IF  tel_nrfinchq = 0 THEN
                                    ASSIGN tel_nrfinchq = tel_nrinichq.
        
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
                  
                    END. /*  Fim do EDITING  */

                    
                    /* Validacao Provisorio/Permanente */
                    ASSIGN aux_confirma = "".

                    UPDATE aux_confirma WITH FRAME f_prov_i.
                    
                    HIDE FRAME f_prov_i NO-PAUSE.
                    
                    IF  aux_confirma = "S"   THEN 
                       DO:
                           ASSIGN aux_dtvalcor = glb_dtmvtopr + 1
                                  aux_flprovis = TRUE.
                           
                           DO WHILE TRUE:
                          
                               IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtvalcor)))
                               OR  CAN-FIND(crapfer WHERE
                                            crapfer.cdcooper = glb_cdcooper  AND
                                            crapfer.dtferiad = aux_dtvalcor) 
                               THEN DO:
                                     ASSIGN aux_dtvalcor = aux_dtvalcor + 1.
                               END.
                               ELSE LEAVE.
                           END.
                    END.
                    ELSE
                        ASSIGN aux_flprovis = FALSE. 

                    IF   aux_flprovis = FALSE THEN
                         aux_flimprim = TRUE.
                    
                    /* Fim Validacao Provisorio/Permanente */

                    LEAVE.
                END. /* Fim do bloco */ 

    
                IF  tel_nrfinchq = 0 THEN
                    ASSIGN tel_nrfinchq = tel_nrinichq.

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
                       INPUT aux_flprovis,
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
                               tel_nrtalchq = tt-dctror.nrtalchq
                               tel_nrctachq = tt-dctror.nrctachq.
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
            END.  /*  Fim do DO WHILE TRUE  */
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                LEAVE Princ.  /* Volta pedir a opcao para o operador */
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
    
                    IF  par_pedsenha THEN
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
    
                IF  TEMP-TABLE tt-custdesc:HAS-RECORDS THEN
                    DO:
                        OPEN QUERY q_custdesc FOR EACH tt-custdesc NO-LOCK.
               
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                UPDATE b_custdesc WITH FRAME f_custdesc.
                                LEAVE.
                        END.
               
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            DO:
                                EMPTY TEMP-TABLE tt-custdesc.
                                HIDE FRAME f_custdesc NO-PAUSE.
                                CLOSE QUERY q_custdesc.
               
                                ASSIGN glb_cdcritic = 79.
                                RUN fontes/critic.p.
                                MESSAGE glb_dscritic.
                                ASSIGN glb_cdcritic = 0.
                                NEXT.
                            END.
            
                        RUN fontes/confirma.p 
                            ( INPUT "Deseja continuar a operacao?",
                             OUTPUT aux_confirma ).
                  
                        HIDE FRAME f_custdesc NO-PAUSE.
                    
                        CLOSE QUERY q_custdesc.
            
                        IF  aux_confirma <> "S"   THEN DO:
                            NEXT.
                        END.
                    END.
    
                RUN grava-dados.
    
            IF  CAN-FIND(FIRST tt-criticas) THEN
                DO:
                    HIDE FRAME f_lanctos NO-PAUSE.
            
                    BELL.
            
                    ASSIGN aux_contador = 0.
            
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
            
                                    ASSIGN aux_contador = 0.
                                    PAUSE MESSAGE
                                    "Tecle <Entra> para continuar...".
                                    CLEAR FRAME f_erros ALL NO-PAUSE.
                                    LEAVE.
            
                                END.  /*  Fim do DO WHILE TRUE  */
            
                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                    DO:
                                        CLEAR FRAME f_erros ALL NO-PAUSE.
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
            
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
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
    
            IF  NOT CAN-FIND(FIRST tt-criticas) AND
                KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN 
                DO:
                    CLEAR FRAME f_dctror NO-PAUSE.
                    HIDE MESSAGE NO-PAUSE.
                    MESSAGE "Inclusao efetuada com sucesso!".
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

/* ......................................................................... */

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
          INPUT 2, /*  par_stlcmexc - Exclusão */
          INPUT 1, /*  par_stlcmcad - Inclusão */
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















