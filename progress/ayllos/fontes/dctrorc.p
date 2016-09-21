/* ............................................................................

   Programa: Fontes/dctrorc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 08/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela DCTROR.

   Alteracoes: 26/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               06/11/98 - Tratar situacao em prejuizo (Deborah).

               16/07/2003 - Alterar a conta do convenio do BB de fixo para
                            a variavel aux_lsconta2 ou aux_lsconta3 (Fernando).

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

               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "CAN FIND" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               16/03/2010 - Adaptacao Projeto IF CECRED (Guilherme).

               08/06/2011 - Adaptacao para uso de BO. (André - DB1)
               
               13/12/2011 - Inclusão de parametro de saída tel_dtvalcor 
                            (André R./Supero)
............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0095tt.i }
{ includes/var_dctror.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0095 AS HANDLE                                         NO-UNDO.
DEF VAR aux_flprovis AS LOGI                                           NO-UNDO.

IF  NOT VALID-HANDLE(h-b1wgen0095)  THEN
    RUN sistema/generico/procedures/b1wgen0095.p
        PERSISTENT SET h-b1wgen0095.

Princ: DO WHILE TRUE:

    EMPTY TEMP-TABLE tt-dctror.
    ASSIGN tel_nmprimtl = ""
           tel_cdsitdtl = 0
           tel_dssitdtl = ""
           tel_dtemscor = ?
           tel_cdhistor = 0
           tel_nrinichq = 0
           tel_nrfinchq = 0
           tel_nrctachq = 0
           tel_dsprovis = "".
    
    RUN busca-dados.
    IF  RETURN-VALUE <> "OK" THEN
        LEAVE Princ.
    
    FIND FIRST tt-dctror NO-LOCK NO-ERROR.
    
    IF  AVAIL tt-dctror THEN
        DO:
            ASSIGN tel_nmprimtl = tt-dctror.nmprimtl
                   tel_cdsitdtl = tt-dctror.cdsitdtl
                   tel_dssitdtl = tt-dctror.dssitdtl.
    
            IF  tel_tptransa = 2 THEN
                ASSIGN tel_nrinichq = tt-dctror.nrinichq.
    
            DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl WITH FRAME f_dctror.
        END.

    IF  tel_tptransa = 2  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
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
                      INPUT "",
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
    
                                ASSIGN tel_cdhistor = 0
                                       tel_nrfinchq = 0
                                       tel_dtemscor = ?.
                                DISPLAY tel_dtemscor tel_cdhistor tel_nrfinchq
                                        tel_dtvalcor
                                        WITH FRAME f_dctror.
    
                                LEAVE Princ.
                            END.
                    END.

                IF   tel_dtvalcor <> ? THEN
                     tel_dsprovis = "SIM".
                ELSE
                     tel_dsprovis = "NAO".
                
                DISPLAY tel_dtemscor  tel_cdhistor
                        tel_nrctachq  tel_nrfinchq 
                        tel_dtvalcor  tel_dsprovis
                        WITH FRAME f_dctror.
                        
            END.  /*  Fim do DO WHILE TRUE  */
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                LEAVE Princ. 
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






