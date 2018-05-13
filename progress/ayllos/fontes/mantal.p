/* ............................................................................

   Programa: Fontes/mantal.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/92.                     Ultima atualizacao: 13/11/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MANTAL - Permitir o cancelamento de cheques.

   Alteracoes: 20/07/94 - Acerto no display da data do ultimo cheque.Nao mostra
                          quando o talao ainda nao foi utilizado (Deborah).

               28/10/94 -Alterado para incluir o indicador de cheque 6 (Odair).

               07/07/95 - Alteracao geral da tela - novo procedimento de can-
                          celamento de cheques (Edson).

               26/03/97 - Alterado para nao permitir operacao com talanarios
                          cujo o titular teve a conta transferida (Edson).

               12/01/99 - Alterado para tratar os talonarios do Bancoob 
                          (Deborah).

               01/10/1999 - Acerto na leitura do crapchq (Deborah). 

               12/09/2000 - Log da tela Mantal (Margarete/Planner).
               
               10/12/2002 - Release para nao prender registro (Margarete).
 
               07/03/2003 - Nao permitir baixar o cheque se ha pendencias no
                            ccf (Edson).

               30/07/2004 - Nao permitir baixar o cheque se o cheque foi des-
                            contado ou custodiado (Edson / Ze Eduardo).
                            
               15/09/2004 - Tratar conta integracao (Margarete).              
               
               07/01/2005 - Imprimir o termo de cancelamento (Evandro).

               14/04/2005 - Ajuste na rotina que verifica se o cheque esta
                            em custodia ou descontado (Edson).
               
               10/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               02/12/2005 - Ajustes na conversao crapchq/crapfdc (Edson).

               31/01/2006 - Unificacao dos bancos - SQLWorks - Luciane.
               
               06/02/2006 - Inclusao da opcao USE-INDEX na pesquisa da tabela
                            crapneg - SQLWorks - Andre

               20/02/2006 - Consertada opcao B para nao permitir impressao, 
                            caso nao tenha sido criado pelo menos 1 registro
                            na w_cheques (Diego).
              
               19/04/2006 - Efetuado acerto na opcao B, nao estava
                            sendo efetuada impressao das criticas(Mirtes)
                            
               25/04/2006 - Nao estava imprimindo o relatorio (Magui)

               18/09/2006 - Efetuado controle para arquivo vazio (Diego).

               19/01/2007 - Alterado formato das variaveis do tipo DATE para
                            "99/99/9999" (Elton).
                            
               13/02/2007 - Alteracao nas chaves do crapfdc e crapcor (BANCOOB)
                            (Ze).
                            
               06/03/2007 - Substituicao do campo crapcch.flgstlcm pelo 
                            crapcch.tpopelcm (Evandro).
                            
               18/04/2007 - Somente atualizar registros na crapcch quando nao
                            for BANCOOB (Evandro).
                            
               23/01/2009 - Quando for movimentacao BB, a conta ITG deve estar
                            ativa (Evandro).
                            
               29/01/2009 - Permitir movimentacao BB quando for CONTA BASE e
                            nao tiver ITG ativa (Evandro).
                            
               16/03/2010 - Adaptacoes Projeto IF CECRED(Guilherme).
               
               14/06/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               14/11/2014 - Inclusão do tratamento para limpar campos que 
                            identificam que cheque esta na TIC ao tentar cancelar
                            folha de cheque(SD-175296 Odirlei-AMcom)
               
               14/11/2014 - Ajustes para mnigração da Concredi e Credimilsul,
                            permitir cadastrar cheques da cooperativa origem
                            (Odirlei-AMcom)             

               13/11/2015 - Ajustes para exibir as criticas durente o 
                            Grava_Dados da bo94, e não apenas os erros
                            (Douglas - Chamado 351208)
............................................................................ */


{ sistema/generico/includes/b1wgen0094tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }


DEF STREAM str_1.
               
DEF        VAR tel_dtaltera AS DATE    FORMAT "99/99/9999"           NO-UNDO. 
DEF        VAR tel_nrdconta AS INTE    FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_cdbanchq LIKE crapfdc.cdbanchq                    NO-UNDO.
DEF        VAR tel_cdagechq LIKE crapfdc.cdagechq                    NO-UNDO.
DEF        VAR tel_nrctachq AS DECI    FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrinichq AS INTE    FORMAT "zzz,zzz,9"            NO-UNDO.
DEF        VAR tel_nrfimchq AS INTE    FORMAT "zzz,zzz,9"            NO-UNDO.
DEF        VAR tel_reganter AS CHAR    FORMAT "x(70)" EXTENT 7       NO-UNDO.

DEF        VAR aux_nmdcampo AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_contador AS INTE                                  NO-UNDO.
DEF        VAR aux_nrinichq AS INTE                                  NO-UNDO.
DEF        VAR aux_nrfimchq AS INTE                                  NO-UNDO.
DEF        VAR aux_dtemscch AS DATE                                  NO-UNDO.  
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR tel_tpcheque AS CHAR    FORMAT "x(9)"                 NO-UNDO.
DEF        VAR tel_dtlibera AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdpesqui AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_exclutic AS CHAR                                  NO-UNDO.
DEF        VAR aux_cont     AS INTE                                  NO-UNDO.
DEF        VAR aux_nrdrowid AS ROWID                                 NO-UNDO.
DEF        VAR aux_msg      AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdagechq AS INTEGER                               NO-UNDO.
DEF        VAR aux_cdageant AS INTEGER                               NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
   
/* variaveis para impressao */

DEF        VAR par_flgrodar AS LOGI INIT TRUE                        NO-UNDO.
DEF        VAR par_flgfirst AS LOGI INIT TRUE                        NO-UNDO.
DEF        VAR par_flgcance AS LOGI                                  NO-UNDO.
      
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGI                                  NO-UNDO.
DEF        VAR aux_nrdconta AS INTE  FORMAT "zzzz,zzz,9"             NO-UNDO.
DEF        VAR h-b1wgen0094 AS HANDLE                                NO-UNDO.
DEF        VAR h-b1wgen0014 AS HANDLE                                NO-UNDO.
DEF        VAR h-b1wgen0095 AS HANDLE                                NO-UNDO.

DEF VAR teste AS INTE NO-UNDO.

DEF TEMP-TABLE w_cheques LIKE tt-cheques.
DEF TEMP-TABLE w_criticas LIKE tt-criticas.

DEF QUERY q_chequedc FOR tt-chequedc.

DEF BROWSE b_chequedc QUERY q_chequedc
    DISP tt-chequedc.nrdconta COLUMN-LABEL "Favorecido"
         tt-chequedc.nmprimtl NO-LABEL              WIDTH 50
         tt-chequedc.nrcheque COLUMN-LABEL "Cheque" WIDTH 7
    WITH 7 DOWN NO-BOX CENTERED WIDTH 72.


FORM b_chequedc HELP "Escolha com as setas, pgant, pgseg e tecle <Entra>"
     SKIP
     "-----------------------------------" AT 3
     SPACE(0)
     "-----------------------------------"
     tel_tpcheque AT 5  LABEL "Cheque em"
     tel_dtlibera AT 47 LABEL "Liberacao para" SKIP
     tel_cdpesqui AT 3  LABEL "Digitado em"
     WITH ROW 6 COL 1 WIDTH 76 OVERLAY CENTERED SIDE-LABELS 
        TITLE " CHEQUES EM CUSTODIA/DESCONTO " FRAME f_chequedc.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  7 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com o opcao desejada (B ou D)."
     SKIP(1)
     tel_nrdconta AT  4 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Entre com o numero da conta do associado."
     tel_nmprimtl AT 26 LABEL "Titular"
     SKIP (1)
     "Numeracao"  AT 54 SKIP
     "Banco      Agencia     Conta Cheque         Inicial         Final" AT 05
     SKIP(1)
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_mantal.

FORM tel_cdbanchq AT 05 AUTO-RETURN HELP "Entre com codigo do banco do cheque."
     tel_cdagechq AT 18 AUTO-RETURN HELP "Entre com codigo da agencia do cheque."
     tel_nrctachq AT 30 AUTO-RETURN HELP "Entre com a conta base do talonario."
     tel_nrinichq AT 47 AUTO-RETURN HELP "Entre com o numero inicial do cheque."
     tel_nrfimchq AT 61 AUTO-RETURN HELP "Entre com o numero final do cheque."
     WITH ROW 13 COLUMN 2 OVERLAY NO-BOX NO-LABELS FRAME f_cancela.

FORM tel_reganter[1] AT 05 SKIP
     tel_reganter[2] AT 05 SKIP
     tel_reganter[3] AT 05 SKIP
     tel_reganter[4] AT 05 SKIP
     tel_reganter[5] AT 05 SKIP
     tel_reganter[6] AT 05 SKIP
     tel_reganter[7] AT 05
     WITH ROW 14 COLUMN 2 OVERLAY NO-BOX NO-LABELS FRAME f_cancelados.

FORM SKIP(1)
     tel_dsimprim  AT  7
     tel_dscancel  AT 27
     SKIP(1)
     WITH ROW 16 CENTERED OVERLAY NO-LABELS WIDTH 42
          TITLE "Impressao do termo de cancelamento" FRAME f_imprime.

/* Buscar a agencia */
ON LEAVE OF tel_cdbanchq IN FRAME f_cancela DO:
       
    /* Carrega a agencia de acordo com cada banco */
    IF  NOT VALID-HANDLE(h-b1wgen0094) THEN
        RUN sistema/generico/procedures/b1wgen0094.p
           PERSISTENT SET h-b1wgen0094.

    RUN Busca_Agencia IN h-b1wgen0094
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT INPUT tel_cdbanchq,
         OUTPUT tel_cdagechq,
         OUTPUT TABLE tt-erro).

    ASSIGN aux_cdagechq = tel_cdagechq.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.
          
            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    PAUSE.
                END.
                
            RETURN NO-APPLY.
                  
        END.
    ELSE
        DISPLAY tel_cdagechq WITH FRAME f_cancela.
END.

/* validar agencia*/
ON LEAVE OF tel_cdagechq IN FRAME f_cancela DO:
    
    ASSIGN tel_cdagechq = INPUT tel_cdagechq.
    ASSIGN tel_cdbanchq = INPUT tel_cdbanchq.
    
    IF aux_cdagechq <> tel_cdagechq THEN 
    DO:
        
        IF  NOT VALID-HANDLE(h-b1wgen0095)  THEN
            RUN sistema/generico/procedures/b1wgen0095.p
                PERSISTENT SET h-b1wgen0095.

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
              INPUT "A",
             OUTPUT aux_cdageant,
             OUTPUT aux_nmdcampo,
             OUTPUT TABLE tt-erro ) NO-ERROR.
       
        
        IF  VALID-HANDLE(h-b1wgen0095)  THEN
            DELETE PROCEDURE h-b1wgen0095.

        IF  RETURN-VALUE <> "OK" OR  ERROR-STATUS:ERROR  THEN
        DO:

            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
            DO:
                MESSAGE tt-erro.dscritic.
                PAUSE 6.
                RETURN NO-APPLY.       
            END.
        END.
        IF tel_cdagechq <> aux_cdageant THEN
        DO:
            
            MESSAGE "Agencia do cheque invalida, "
                  + "para este banco "
                  + "são permitidas agencias " 
                  + STRING(aux_cdageant) + " e " 
                  + STRING(aux_cdagechq).
            
            PAUSE 6.
            RETURN NO-APPLY.
       END.            
    END. /*Fim aux_cdagechq <> tel_cdagechq*/              

END.

ON  ENTRY, VALUE-CHANGED OF b_chequedc DO:
    IF  AVAIL tt-chequedc  THEN
        DO:
            ASSIGN tel_tpcheque = IF tt-chequedc.tpcheque = "C" THEN "CUSTODIA"
                                                                ELSE "DESCONTO"
                   tel_dtlibera = tt-chequedc.dtlibera
                   tel_cdpesqui = tt-chequedc.cdpesqui.

            DISPLAY tel_tpcheque tel_dtlibera tel_cdpesqui 
                WITH FRAME f_chequedc.
        END.    
END.

RUN fontes/inicia.p.

ASSIGN glb_cdcritic = 0
       glb_cddopcao = "B"
       tel_dtaltera = glb_dtmvtolt
       aux_dtemscch = glb_dtmvtolt.

VIEW FRAME f_moldura.

PAUSE(0).

DO WHILE TRUE:

   IF  NOT VALID-HANDLE(h-b1wgen0094) THEN
        RUN sistema/generico/procedures/b1wgen0094.p
           PERSISTENT SET h-b1wgen0094.
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        NEXT-PROMPT tel_nrdconta WITH FRAME f_mantal.
    
        UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_mantal
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
                            DISPLAY tel_nrdconta WITH FRAME f_mantal.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.
        END.

        ASSIGN glb_nrcalcul = tel_nrdconta.
    
        RUN Busca_Dados.
    
        IF  RETURN-VALUE <> "OK" THEN
            NEXT.
    
        DISPLAY tel_nmprimtl WITH FRAME f_mantal.
        CLEAR FRAME f_cancela NO-PAUSE.
        HIDE FRAME f_cancelados NO-PAUSE.
      
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "MANTAL"   THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0094) THEN
                        DELETE OBJECT h-b1wgen0094.
                    
                    HIDE FRAME f_cancelados.
                    HIDE FRAME f_cancela.
                    HIDE FRAME f_mantal.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                DO:
                    ASSIGN glb_cdcritic = 0.
                    NEXT.
                END.
       END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   HIDE FRAME f_cancelados NO-PAUSE.

    ASSIGN tel_cdbanchq = 0
           tel_cdagechq = 0
           tel_nrctachq = 0
           tel_nrinichq = 0
           tel_nrfimchq = 0
           tel_reganter = ""
           aux_nrinichq = 0
           aux_nrfimchq = 0.

    EMPTY TEMP-TABLE w_criticas.
    EMPTY TEMP-TABLE w_cheques.

    /* Verificar se é uma conta migrada da concredi 
           ou credimilsul*/
    FIND FIRST craptco 
        WHERE craptco.cdcooper = glb_cdcooper AND
              craptco.nrdconta = tel_nrdconta AND
             (craptco.cdcopant = 4 OR 
              craptco.cdcopant = 15 ) NO-LOCK NO-ERROR.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
        
        UPDATE tel_cdbanchq
               tel_cdagechq WHEN AVAIL craptco
               tel_nrctachq
               tel_nrinichq
               tel_nrfimchq WITH FRAME f_cancela
        EDITING:

            READKEY.
            APPLY LASTKEY.
            
            HIDE MESSAGE NO-PAUSE.
      
            IF  GO-PENDING THEN
                DO:
                    RUN Valida_Dados.
      
                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            {sistema/generico/includes/foco_campo.i
                                &VAR-GERAL=SIM
                                &NOME-FRAME="f_cancela"
                                &NOME-CAMPO=aux_nmdcampo }
                        END.
                END.
        END. /*  Fim do EDITING  */

        IF  TEMP-TABLE tt-chequedc:HAS-RECORDS THEN
            DO:
                OPEN QUERY q_chequedc FOR EACH tt-chequedc NO-LOCK.
       
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
				    UPDATE b_chequedc WITH FRAME f_chequedc.
                    LEAVE.
                END.
       
                IF  CAN-DO("END-ERROR,GO",KEYFUNCTION(LASTKEY)) THEN
                    EMPTY TEMP-TABLE tt-chequedc.
       
                RUN fontes/confirma.p (  INPUT "Deseja continuar a operacao?",
                                        OUTPUT aux_confirma ).
                
                HIDE FRAME f_chequedc NO-PAUSE.
          
                CLOSE QUERY q_chequedc.
       
                IF  aux_confirma <> "S" THEN
                    NEXT.
                
            END.
      
        RUN Grava_Dados.
      
        IF  glb_cdcritic = 0   THEN
            DO:
                ASSIGN tel_reganter[7] = tel_reganter[6]
                       tel_reganter[6] = tel_reganter[5]
                       tel_reganter[5] = tel_reganter[4]
                       tel_reganter[4] = tel_reganter[3]
                       tel_reganter[3] = tel_reganter[2]
                       tel_reganter[2] = tel_reganter[1]
       
                       tel_reganter[1] =
                                 STRING(tel_cdbanchq,"z,zz9") + "        " +
                                 STRING(tel_cdagechq,"z,zz9") + "       " +
                                 STRING(tel_nrctachq,"zzzz,zzz,9") + "       " +
                                 STRING(tel_nrinichq,"zzz,zzz,z") + "     " +
                                 STRING(tel_nrfimchq,"zzz,zzz,z")
       
                       tel_cdbanchq = 0
                       tel_cdagechq = 0
                       tel_nrctachq = 0
                       tel_nrinichq = 0
                       tel_nrfimchq = 0.
       
                DISPLAY tel_cdagechq WITH FRAME f_cancela.
                DISPLAY tel_reganter WITH FRAME f_cancelados.
            END.
        ELSE
        IF  glb_cdcritic = 749   THEN
            glb_cdcritic = 0.
           
    END.  /*  Fim do DO WHILE TRUE  */

    IF  glb_cddopcao = "B"  OR
        CAN-FIND(FIRST w_criticas)  THEN
        DO:
            DISPLAY      tel_dsimprim tel_dscancel  WITH FRAME f_imprime.
            CHOOSE FIELD tel_dsimprim tel_dscancel  WITH FRAME f_imprime.
            
            IF  FRAME-VALUE = tel_dsimprim   THEN
                RUN imprime_termo.
                 
            HIDE FRAME f_imprime.
        END.
                                       
END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0094) THEN
    DELETE OBJECT h-b1wgen0094.

/* ......................................................................... */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-erro.

    /* Carrega a agencia de acordo com cada banco */
    IF  NOT VALID-HANDLE(h-b1wgen0094) THEN
        RUN sistema/generico/procedures/b1wgen0094.p
           PERSISTENT SET h-b1wgen0094.
    
    RUN Busca_Dados IN h-b1wgen0094
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT glb_cddopcao,
          INPUT YES,
         OUTPUT TABLE tt-infoass,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    FIND FIRST tt-infoass NO-ERROR.

    IF  AVAILABLE tt-infoass THEN
        ASSIGN tel_nmprimtl = tt-infoass.nmprimtl.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Valida_Dados:

    EMPTY TEMP-TABLE tt-erro.

    /* Carrega a agencia de acordo com cada banco */
    IF  NOT VALID-HANDLE(h-b1wgen0094) THEN
        RUN sistema/generico/procedures/b1wgen0094.p
           PERSISTENT SET h-b1wgen0094.
    
    DO WITH FRAME f_cancela:
    
            ASSIGN tel_nrctachq
                   tel_cdbanchq
                   tel_nrinichq
                   tel_nrfimchq.
        END.
    
    RUN Valida_Dados IN h-b1wgen0094
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdconta, 
          INPUT tel_nrctachq,
          INPUT tel_cdbanchq,
          INPUT tel_cdagechq,
          INPUT tel_nrinichq,
          INPUT tel_nrfimchq,
         OUTPUT aux_nmdcampo,
         OUTPUT aux_nrinichq,
         OUTPUT aux_nrfimchq,
         OUTPUT TABLE tt-chequedc,
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
    
    EMPTY TEMP-TABLE tt-criticas.
    EMPTY TEMP-TABLE tt-cheques.
    EMPTY TEMP-TABLE tt-erro.
    
    /* Carrega a agencia de acordo com cada banco */
    IF  NOT VALID-HANDLE(h-b1wgen0094) THEN
        RUN sistema/generico/procedures/b1wgen0094.p
           PERSISTENT SET h-b1wgen0094.

    DO WITH FRAME f_cancela:
    
		ASSIGN tel_nrctachq
			   tel_cdbanchq
			   tel_nrinichq
			   tel_nrfimchq.
    END.
    
    /* verificar se existem registros que podem apresentar
       critica 950 - Cheque Custodiado/Descontado em outra IF.
       Pois deve permitir o usuario limpar os campos para continuar 
       o procedimento, pois o cheque esta em posse do cooperado
        e não em outra instituição */
    IF glb_cddopcao = "B"    THEN
    DO:
        RUN pc_limpa_TIC(OUTPUT aux_exclutic).
    END.

    RUN Grava_Dados IN h-b1wgen0094
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdconta,
          INPUT 1, /*idseqttl*/
          INPUT tel_nrctachq,
          INPUT tel_cdbanchq,
          INPUT tel_cdagechq,
          INPUT aux_nrinichq,
          INPUT aux_nrfimchq,
          INPUT TRUE, /*flgerlog*/
         OUTPUT TABLE tt-criticas,
         OUTPUT TABLE tt-cheques,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
            DO:
                MESSAGE tt-erro.dscritic.
            END.                    
            
            RETURN "NOK".
        END.

    /* Verificar se existe alguma critica para o cheque */
    IF  aux_nrinichq = aux_nrfimchq AND TEMP-TABLE tt-criticas:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-criticas 
                 WHERE tt-criticas.cdbanchq = tel_cdbanchq
                   AND tt-criticas.cdagechq = tel_cdagechq
                   AND tt-criticas.nrctachq = tel_nrctachq
                   AND tt-criticas.nrcheque = tel_nrinichq
                 NO-ERROR.
            IF  AVAILABLE tt-criticas THEN
            DO:
                MESSAGE tt-criticas.dscritic.
            END.                    

            RETURN "NOK".
        END.

    RUN Atualiza_Tabelas.

    IF  VALID-HANDLE(h-b1wgen0094) THEN
        DELETE OBJECT h-b1wgen0094.
    
    RETURN "OK".

END PROCEDURE. /* Grava_Dados */

PROCEDURE Atualiza_Tabelas:

    FOR EACH tt-criticas:
        CREATE w_criticas.
        BUFFER-COPY tt-criticas TO w_criticas.
    END.

    FOR EACH tt-cheques:
        CREATE w_cheques.
        BUFFER-COPY tt-cheques TO w_cheques.
    END.

    RETURN "OK".

END PROCEDURE. /*Atualiza_Tabelas*/

PROCEDURE imprime_termo:
      
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    /* Carrega a agencia de acordo com cada banco */
    IF  NOT VALID-HANDLE(h-b1wgen0094) THEN
        RUN sistema/generico/procedures/b1wgen0094.p
           PERSISTENT SET h-b1wgen0094.
    
    RUN Imprime_Termo IN h-b1wgen0094
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT glb_dtmvtolt, 
          INPUT glb_nmoperad, 
          INPUT aux_nmendter, 
          INPUT tel_nrdconta, 
          INPUT TRUE, /*flgerlog*/
          INPUT TABLE w_criticas,
          INPUT TABLE w_cheques,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.
           
            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".
        END.

     /*** nao necessario ao programa somente para nao dar erro 
              de compilacao na rotina de impressao ****/
    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                             NO-LOCK NO-ERROR.

    { includes/impressao.i }

    RETURN "OK".

END PROCEDURE.

PROCEDURE cria_critica:

    CREATE w_criticas.
    ASSIGN w_criticas.cdbanchq = tel_cdbanchq
           w_criticas.cdagechq = tel_cdagechq
           w_criticas.nrctachq = tel_nrctachq
           w_criticas.cdcritic = glb_cdcritic
           w_criticas.nrcheque = glb_nrchqcdv
           glb_cdcritic        = 0.

END PROCEDURE.


PROCEDURE pc_limpa_TIC:

    DEF OUTPUT PARAM pr_exclutic AS CHAR           NO-UNDO.

    ASSIGN pr_exclutic = "OK".

    /* varrer cheques selecionados para limpeza*/
    Cheques: DO aux_cont = aux_nrinichq TO aux_nrfimchq:

        /* localizar folha de cheque*/
        FIND crapfdc WHERE 
             crapfdc.cdcooper = glb_cdcooper   AND
             crapfdc.cdbanchq = tel_cdbanchq   AND
             crapfdc.cdagechq = tel_cdagechq   AND
             crapfdc.nrctachq = tel_nrctachq   AND
             crapfdc.nrcheque = aux_cont
             USE-INDEX crapfdc1 
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        /* verificar se possui informacoes na TIC */
        IF AVAILABLE crapfdc AND
           (crapfdc.cdbantic <> 0 OR 
            crapfdc.cdagetic <> 0 OR
            crapfdc.nrctatic <> 0) THEN
        DO:
          aux_confirma = "N".
          BELL.
          MESSAGE COLOR normal
                  "Cheque " + string(aux_cont) + " consta como " + 
                  "custodiado/descontado em outra IF. ".
          MESSAGE COLOR normal
                  "Deseja limpar restrições e continuar operacao?"
          UPDATE aux_confirma.

          /* caso sim, dele gerar log e limpar campos*/
          IF  aux_confirma = "S" THEN
          DO:

              /* Gravar log da limpeza */
              RUN sistema/generico/procedures/b1wgen0014.p 
                                     PERSISTENT SET h-b1wgen0014.

              RUN gera_log IN h-b1wgen0014 (INPUT glb_cdcooper,
                                            INPUT glb_cdoperad,
                                            INPUT "",
                                            INPUT "AYLLOS",
                                            INPUT "Limpeza das informacoes da TIC no chq",
                                            INPUT glb_dtmvtolt,
                                            INPUT TRUE,
                                            INPUT TIME,
                                            INPUT 1,
                                            INPUT glb_nmdatela,
                                            INPUT crapfdc.nrdconta,
                                            OUTPUT aux_nrdrowid).
                
                /* Logar que bco do cheque */
                RUN gera_log_item IN h-b1wgen0014 
                     (INPUT aux_nrdrowid,
                      INPUT "Bco.Chq",
                      INPUT "",
                      INPUT crapfdc.cdbanchq).

                /* Logar agencia do cheque */
                RUN gera_log_item IN h-b1wgen0014 
                    (INPUT aux_nrdrowid,
                     INPUT "Age.chq",
                     INPUT "",
                     INPUT STRING(crapfdc.cdagechq)).
                
                /* Logar que cta do cheque */
                RUN gera_log_item IN h-b1wgen0014 
                     (INPUT aux_nrdrowid,
                      INPUT "Cta.Chq",
                      INPUT "",
                      INPUT crapfdc.nrctachq).

                /* Logar nr.cheque */
                RUN gera_log_item IN h-b1wgen0014 
                    (INPUT aux_nrdrowid,
                     INPUT "Nr.cheque",
                     INPUT "",
                     INPUT STRING(crapfdc.nrcheque)).
                /* Logar bco*/
                RUN gera_log_item IN h-b1wgen0014 
                    (INPUT aux_nrdrowid,
                     INPUT "Bco.Custodiado",
                     INPUT "",
                     INPUT STRING(crapfdc.cdbantic)).
                /* Logar agencia */
                RUN gera_log_item IN h-b1wgen0014 
                    (INPUT aux_nrdrowid,
                     INPUT "Age.Custodiado",
                     INPUT "",
                     INPUT STRING(crapfdc.cdagetic)).
                /* Logar Banco/Caixa */
                RUN gera_log_item IN h-b1wgen0014 
                    (INPUT aux_nrdrowid,
                     INPUT "Cta.Custodiado",
                     INPUT "",
                     INPUT STRING(crapfdc.nrctatic)).
             
                DELETE PROCEDURE h-b1wgen0014.

              ASSIGN crapfdc.cdbantic = 0
                     crapfdc.cdagetic = 0
                     crapfdc.nrctatic = 0.
              VALIDATE crapfdc. 

              ASSIGN pr_exclutic = "OK".

          END.
          ELSE
          DO:
            NEXT.
          END.

        END.
    END. /* Fim loop cheques*/
END PROCEDURE.

/* .......................................................................... */







