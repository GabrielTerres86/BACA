/* .............................................................................

   Programa: Fontes/proepr_l.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/96.                         Ultima atualizacao: 05/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento das liquidacoes de emprestimos.
   
   Alteracoes: 29/03/2011 - Estruturar p/utilizar BO e BROWSE (Jose Luis, DB1)

               04/07/2012 - Somar saldo devedor dos emprestimos a serem
                            liquidados (Gabriel).
                            
               25/03/2013 - Enviar o numero do contrato para a validacao
                            da liquidacao (Gabriel).    
                            
               28/06/2013 - Enviar como parametro a linha de credito em 
                            questao para a abertura de liquidacao de contratos
                            (Gabriel).
                            
               24/02/2014 - Adicionado param. de paginacao em proc. 
                            obtem-dados-emprestimos em BO 0002.(Jorge)                                      

               28/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
               
               20/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)       
                            
               05/08/2015 - Ajustes Referente Projeto 215 - DV 3 (Daniel)              
............................................................................. */

DEF INPUT        PARAM par_cdlcremp AS INTE                       NO-UNDO.
DEF INPUT        PARAM par_vlemprst AS DECIMAL                    NO-UNDO.
DEF INPUT-OUTPUT PARAM par_dsctrliq AS CHAR                       NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE                                    NO-UNDO.
DEF VAR tot_vlsdeved AS DECI                                      NO-UNDO.
DEF VAR aux_qtregist AS INTE                                      NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0002tt.i }

DEF BUFFER btt-dados-epr FOR tt-dados-epr.

DEF QUERY q_epr FOR tt-dados-epr SCROLLING.
 
DEF BROWSE b_epr QUERY q_epr 
    DISP tt-dados-epr.idseleca COLUMN-LABEL ""           FORMAT "x(01)"
         tt-dados-epr.cdlcremp COLUMN-LABEL "Lin"        FORMAT "9999"
         tt-dados-epr.cdfinemp COLUMN-LABEL "Fin"        FORMAT "999"
         tt-dados-epr.nrctremp COLUMN-LABEL "Contrato"   FORMAT "zz,zzz,zz9"
         tt-dados-epr.dtmvtolt COLUMN-LABEL "Data"       FORMAT "99/99/9999"
         tt-dados-epr.vlemprst COLUMN-LABEL "Emprestado" FORMAT "zzzz,zz9.99"
         tt-dados-epr.qtpreemp COLUMN-LABEL "Parc."      FORMAT "zz9"
         tt-dados-epr.vlpreemp COLUMN-LABEL "Valor"      FORMAT "zz,zz9.99"
         tt-dados-epr.vlsdeved COLUMN-LABEL "Saldo"      FORMAT "zzzz,zz9.99-"
         tt-dados-epr.tipoempr COLUMN-LABEL "Tipo"       FORMAT "x(04)"
         WITH 7 DOWN WIDTH 76 SCROLLBAR-VERTICAL 
         TITLE " Emprestimos a Liquidar ".

DEF FRAME f_epr
          b_epr  
    HELP "Marque os emprestimos com <ENTRA> ou tecle <FIM> para retornar." 
    WITH NO-BOX CENTERED OVERLAY ROW 9.


/* Realiza a busca de dados e pre-selecao dos registros no browse */
RUN Busca_Dados.

IF  RETURN-VALUE <> "OK" THEN
    RETURN "NOK".

DO WITH FRAME f_epr WHILE TRUE ON ENDKEY UNDO, LEAVE:

    /* Pressionar ENTER para selecionar/descelecionar os registros */
    ON "ENTER" OF b_epr IN FRAME f_epr DO:

        HIDE MESSAGE NO-PAUSE.

        /* Procura o registro corrente/selecionado no browse */
        FIND CURRENT tt-dados-epr NO-ERROR.

        IF  NOT AVAILABLE tt-dados-epr THEN
            RETURN NO-APPLY.

        /* Nao permitir selecionar valor zero */
        IF  tt-dados-epr.vlsdeved = 0 THEN 
            DO:
               APPLY "CURSOR-DOWN" TO b_epr IN FRAME f_epr.
               RETURN NO-APPLY.
            END.

        /* Seleciona/Desmarca a linha conforme a interacao do usuario */
        IF  tt-dados-epr.idseleca:SCREEN-VALUE IN BROWSE b_epr = "*" THEN
            ASSIGN 
                tt-dados-epr.idseleca:SCREEN-VALUE IN BROWSE b_epr = ""
                tot_vlsdeved = tot_vlsdeved - tt-dados-epr.vlsdeved.
        ELSE 
            DO:
               /* Conta os registros selecionados */
               FOR EACH btt-dados-epr WHERE btt-dados-epr.idseleca = "*":
                   ACCUMULATE btt-dados-epr.nrctremp (COUNT).
               END.
    
               /* Realiza a validacao */
               RUN Valida_Dados
                   ( INPUT tt-dados-epr.dtmvtolt,
                     INPUT tt-dados-epr.vlsdeved,
                     INPUT tot_vlsdeved,
                     INPUT tt-dados-epr.nrctrem,
                     INPUT ACCUM COUNT btt-dados-epr.nrctremp ).
    
               IF  RETURN-VALUE <> "OK" THEN
                   RETURN NO-APPLY.

               /* atualiza o registro = selecionado! */
               ASSIGN 
                   tt-dados-epr.idseleca:SCREEN-VALUE IN BROWSE b_epr = "*"
                   tot_vlsdeved = tot_vlsdeved + tt-dados-epr.vlsdeved.
            END.

        /* Atualiza o registro na tabela, estava apenas em tela */
        ASSIGN tt-dados-epr.idseleca =
            tt-dados-epr.idseleca:SCREEN-VALUE IN BROWSE b_epr.

        /* Passa a proxima linha para facilitar a digitacao */
        APPLY "CURSOR-DOWN" TO b_epr IN FRAME f_epr.
        RETURN NO-APPLY.

    END. /* "ENTER" */

    /* Pressionar END, atualizar o parametro de retorno e fechar objetos */
    ON "END-ERROR", "F4", "END" OF FRAME f_epr DO:
        
        ASSIGN par_dsctrliq = "".

        /* Separa os contratos selecionados */
        FOR EACH tt-dados-epr WHERE tt-dados-epr.idseleca = "*":
            /* Atualizar parametro de retorno */
            ASSIGN par_dsctrliq = par_dsctrliq + (IF par_dsctrliq = "" 
                                                  THEN "" ELSE ", ") +
                                  TRIM(STRING(tt-dados-epr.nrctremp,
                                              "zz,zzz,zz9")).
        END.

        /* Fecha os objetos */
        CLOSE QUERY q_epr.
        HIDE FRAME f_epr NO-PAUSE.
        APPLY 'WINDOW-CLOSE' TO CURRENT-WINDOW.
        RETURN.

    END. /* "END-ERROR" "F4" "END" */
    
    /* Se nao tiver nenhum contrato a liquidar */
    IF   NOT TEMP-TABLE tt-dados-epr:HAS-RECORDS   THEN
         RETURN "OK".

    MESSAGE "Aguarde...".
    OPEN QUERY q_epr FOR EACH tt-dados-epr NO-LOCK INDEXED-REPOSITION.

    HIDE MESSAGE NO-PAUSE.
    
    ENABLE b_epr WITH FRAME f_epr.

    WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                                   
    HIDE FRAME f_epr NO-PAUSE.
        
    HIDE MESSAGE NO-PAUSE.
    
    LEAVE.
     
END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0002) THEN
    DELETE OBJECT h-b1wgen0002.

HIDE FRAME f_epr NO-PAUSE.

RETURN.

/* .......................................................................... */

/******************************************************************************/
/**    Procedure para buscar os registros p/ a liquidacao de emprestimos     **/
/******************************************************************************/
PROCEDURE Busca_Dados:

    IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
        RUN sistema/generico/procedures/b1wgen0002.p
           PERSISTENT SET h-b1wgen0002.

    EMPTY TEMP-TABLE tt-dados-epr.
    EMPTY TEMP-TABLE tt-erro.

    RUN obtem-dados-emprestimos IN h-b1wgen0002
        ( INPUT glb_cdcooper, /** Cooperativa   **/
          INPUT 0,            /** Agencia       **/
          INPUT 0,            /** Caixa         **/
          INPUT glb_cdoperad, /** Operador      **/
          INPUT "proepr.p",   /** Nome da tela  **/
          INPUT 1,            /** Origem=Ayllos **/
          INPUT tel_nrdconta, /** Num. da conta **/
          INPUT 1,            /** Sq.do titular **/
          INPUT glb_dtmvtolt, /** Data de Movto **/
          INPUT glb_dtmvtopr, /** Data de Movto **/
          INPUT ?,            /** Data de Calc. **/
          INPUT 0,            /** Nr.do Contrato**/
          INPUT "proepr_l.p", /** Tela atual   **/
          INPUT glb_inproces, /** Indic.Process.**/
          INPUT FALSE,        /** Gera log erro **/
          INPUT TRUE,         /** Flag Condic.C.**/
          INPUT 0, /** nriniseq **/
          INPUT 0, /** nrregist **/
          OUTPUT aux_qtregist,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-dados-epr ) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    EMPTY TEMP-TABLE tt-erro.

    /* Pre-selecao das linhas do browse */
    RUN obtem-emprestimos-selecionados IN h-b1wgen0002
        ( INPUT glb_cdcooper, /** Cooperativa   **/
          INPUT 0,            /** Agencia       **/
          INPUT 0,            /** Caixa         **/
          INPUT glb_cdoperad, /** Operador      **/
          INPUT "proepr.p",   /** Nome da tela  **/
          INPUT 1,            /** Origem=Ayllos **/
          INPUT tel_nrdconta, /** Num. da conta **/
          INPUT 1,            /** Sq.do titular **/
          INPUT TRUE,         /** Gera log erro **/
          INPUT par_dsctrliq, /** Contratos Sel. **/
          INPUT par_cdlcremp, /** Linha credito  **/
          INPUT-OUTPUT TABLE tt-dados-epr,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    ASSIGN tot_vlsdeved = 0.

    FOR EACH tt-dados-epr WHERE tt-dados-epr.idseleca = "*" NO-LOCK:

        ASSIGN tot_vlsdeved = tot_vlsdeved +  tt-dados-epr.vlsdeved.

    END.


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**           Procedure para validar a liquidacao de emprestimos             **/
/******************************************************************************/
PROCEDURE Valida_Dados:

    DEF INPUT PARAM par_dtmvtoep AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_vlsdeved AS DECI                              NO-UNDO.
    DEF INPUT PARAM par_tosdeved AS DECI                              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_qtlinsel AS INTE                              NO-UNDO.

    DEF VAR aux_tpdretor AS CHAR                                      NO-UNDO.
    DEF VAR aux_msgretor AS CHAR                                      NO-UNDO.
    DEF VAR aux_confirma AS CHAR                                      NO-UNDO.
    
    IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
        RUN sistema/generico/procedures/b1wgen0002.p
           PERSISTENT SET h-b1wgen0002.

    EMPTY TEMP-TABLE tt-erro.

    RUN valida-liquidacao-emprestimos IN h-b1wgen0002
        ( INPUT glb_cdcooper, /** Cooperativa   **/
          INPUT 0,            /** Agencia       **/
          INPUT 0,            /** Caixa         **/
          INPUT glb_cdoperad, /** Operador      **/
          INPUT "proepr_l.p", /** Nome da tela  **/
          INPUT 1,            /** Origem=Ayllos **/
          INPUT tel_nrdconta, /** Num. da conta **/
          INPUT par_nrctremp,
          INPUT 1,            /** Sq.do titular **/
          INPUT glb_dtmvtolt, /** Dt.do sistema **/
          INPUT par_dtmvtoep, /** Dt.do emprest.**/
          INPUT par_qtlinsel, /** Qt.linhas sel.**/
          INPUT par_vlemprst, /** Tot.Emprestim.**/
          INPUT par_vlsdeved, /** Vl.saldo dev. **/
          INPUT par_tosdeved, /** Tot.saldo dev.**/
          INPUT TRUE,         /** Gera log erro **/
         OUTPUT aux_tpdretor, /** Tp.do retorno **/
         OUTPUT aux_msgretor, /** Msg.de retorno**/
         OUTPUT TABLE tt-erro ) NO-ERROR.
    
    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.
    
           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    /* Tratamento para o retorno da BO, pode ser DISPLAY ou MENSAGEM */
    CASE aux_tpdretor:
        WHEN "D" THEN DO: /* Display */
            DISPLAY aux_msgretor VIEW-AS EDITOR SIZE 41 BY 4 FORMAT "X(78)"
               WITH CENTERED OVERLAY ROW 10 NO-LABELS FRAME f_liquida.

            PAUSE 3 NO-MESSAGE.

            HIDE FRAME f_liquida NO-PAUSE.
            RETURN "NOK".
        END.
        WHEN "M" THEN DO: /* Mensagem */
            ASSIGN aux_confirma = "S".

            BELL.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               ASSIGN aux_confirma = "N".

               MESSAGE COLOR NORMAL aux_msgretor 
                   UPDATE aux_confirma FORMAT "!".

               LEAVE.
            END.  

            IF aux_confirma <> "S" THEN
                RETURN "NOK".
        END.
    END CASE.

    RETURN "OK".

END PROCEDURE. /* Valida_Dados */
