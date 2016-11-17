/* .............................................................................

   Programa: fontes/conta_sfn.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2005.              Ultima atualizacao: 22/07/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Exibir tela da opcao "S" -> SISTEMA FINANCEIRO NACIONAL.

   Alteracoes: 15/04/2005 - Correcao no saldo medio anual (Evandro).

               28/06/2005 - Alimentado campo cdcooper das tabelas crapsfn
                            e crapalt (Diego).

               23/08/2005 - Alterado layout referente Emissao Ficha Cadastral
                            (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               14/10/2005 - Comentados alguns campos refente opcao de impressao
                            deixando apenas a opcao FICHA CADASTRAL na tela
                            (Diego).
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               20/04/2006 - Atribuido glb_nrdevias = 3 para impressao da
                            FICHA CADASTRAL (Diego).
                            
               25/05/2006 - Receber a conta por parametro para poder ser usada
                            tanto pela tela CONTA quanto pela CONTAS (Evandro).
                            
               09/08/2006 - Alterada a variavel de opcao para "tel_desopcao"
                            para nao conflitar com a includes/var_contas.i
                            (Evandro).
               
               13/09/2007 - Alterado para gravar dados das informacoes sobre o
                            inicio do relacionamento do cliente com o banco e
                            mostrar num browser (Elton).
               
               20/04/2009 - Nao Aceitar "Codigo do Banco" e "Codigo da Agencia"
                            quando for 0 (Fernando).
                            
               18/08/2009 - Nao permitir Data de abertura da C/C em outra 
                            instituicao financeira maior que a data de 
                            movimento (Diego).
                            
               29/10/2009 - Permitir alterar Cadastro do Sistema Financeiro
                            Nacional (crapsfn) mesmo com data diferente da
                            data de movimento atual (glb_dtmvtolt) para
                            operadores da "TI" e "COORD.ADM/FINANCEIRO"
                            (GATI - Eder).

               17/02/2010 - Tratamento ICF IF CECRED (Guilherme/Precise).
               
               21/05/2010 - Adaptado para usar BO (Jose Luis, DB1).
               
               22/09/2010 - Bloquear banco igual a zero, bloqueando assim o
                            campo Instituição Financeira (Gabriel - DB1 )

               21/12/2011 - Corrigido warnings (Tiago).
               
               08/04/2014 - Ajuste "WHOLE-INDEX" na leitura da cratsfn
                           (Adriano).
                           
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               22/07/2014 - Alterado forms f_ficha_juridica, f_ficha_fisica da
                            procedure imprimir_ficha. (Reinert)
               
 ........................................................................... */

{ sistema/generico/includes/b1wgen0061tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF STREAM str_1.

DEF        VAR tel_desopcao   AS LOGICAL   
               FORMAT "DADOS SISTEMA FINANCEIRO/EMISSAO FICHA CADASTRAL"      
                                                                      NO-UNDO.
DEF        VAR tel_inpessoa  AS CHAR    FORMAT "x(12)"                NO-UNDO.
DEF        VAR tel_dtabtcct  LIKE crapsfn.dtabtcct                    NO-UNDO.
DEF        VAR tel_cddbanco  LIKE crapsfn.cddbanco                    NO-UNDO.
DEF        VAR tel_cdageban  LIKE crapsfn.cdageban  FORMAT "zzzz9"    NO-UNDO.
DEF        VAR tel_nrdctasf  LIKE crapsfn.nrdconta                    NO-UNDO.
DEF        VAR tel_dgdconta  LIKE crapsfn.dgdconta                    NO-UNDO.
DEF        VAR tel_nminsfin  LIKE crapsfn.nminsfin                    NO-UNDO.
DEF        VAR tel_tpimpres  AS CHAR EXTENT 4
                             INIT["FICHA CADASTRAL","","",""]         NO-UNDO.
DEF        VAR tel_nmagenci  AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR aux_nmarqimp  AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter  AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_flgcance  AS LOGICAL                               NO-UNDO.
DEF        VAR aux_frameval  AS CHAR                                  NO-UNDO.

DEF        VAR rel_dtabtcct  AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rel_totdschq  AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vldscchq  AS DECIMAL                               NO-UNDO.
DEF        VAR rel_qtddschq  AS INT                                   NO-UNDO.
DEF        VAR rel_nmsegntl  AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR rel_dtdemiss  AS CHAR    FORMAT "99/99/9999"           NO-UNDO.

/* variaveis para includes/impressao.i */
DEF        VAR par_flgrodar  AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR aux_flgescra  AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand  AS CHAR                                  NO-UNDO.
DEF        VAR par_flgfirst  AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR tel_dsimprim  AS CHAR FORMAT "x(8)" INIT "Imprimir"    NO-UNDO.
DEF        VAR tel_dscancel  AS CHAR FORMAT "x(8)" INIT "Cancelar"    NO-UNDO.
DEF        VAR par_flgcance  AS LOGICAL                               NO-UNDO.

/* variaveis para includes/cabrel080_1.i */
DEF        VAR rel_nmresemp  AS CHAR FORMAT "x(15)"                   NO-UNDO.
DEF        VAR rel_nmrelato  AS CHAR FORMAT "x(40)" EXTENT 5          NO-UNDO.
DEF        VAR rel_nrmodulo  AS INT  FORMAT "9"                       NO-UNDO.

DEF        VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Excluir",
                                                   "Incluir", 
                                                   "Imprimir" ]       NO-UNDO.
DEF        VAR reg_contador AS INTE                                   NO-UNDO.
DEF        VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["E","I","P"]       NO-UNDO.
DEF        VAR aux_nrdlinha AS INTE                                   NO-UNDO.
DEF        VAR aux_insitcta LIKE crapsfn.insitcta                     NO-UNDO.
DEF        VAR aux_cdmotdem LIKE crapsfn.cdmotdem                     NO-UNDO.
DEF        VAR tel_nmextbcc LIKE crapban.nmextbcc                     NO-UNDO.
DEF        VAR tel_nmageban LIKE crapagb.nmageban                     NO-UNDO.
DEF        VAR tel_nmextttl AS CHAR FORMAT "x(40)"                    NO-UNDO.
DEF        VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                     NO-UNDO.
DEF        VAR rel_nmextttl AS CHAR FORMAT "x(25)"                    NO-UNDO.
DEF        VAR aux_nrdrowid AS ROWID                                  NO-UNDO.
DEF        VAR h-b1wgen0060 AS HANDLE                                 NO-UNDO.
DEF        VAR h-b1wgen0061 AS HANDLE                                 NO-UNDO.
DEF        VAR aux_inpessoa AS INTEGER                                NO-UNDO.
DEF        VAR aux_dtmvtosf AS DATE                                   NO-UNDO.
DEF        VAR aux_dtdenvio AS DATE                                   NO-UNDO.

DEF TEMP-TABLE cratsfn NO-UNDO LIKE tt-crapsfn.

DEF QUERY  q_emficha FOR cratsfn.
DEF QUERY  q_dadosfn FOR cratsfn.

/**** Browser referente a opcao "E" ****/
DEF BROWSE b_emficha QUERY q_emficha
    DISPLAY cratsfn.cddbanco                 COLUMN-LABEL "Bco Dest.    "
            cratsfn.cdageban                 COLUMN-LABEL "Age.Dest.    "
            cratsfn.dtdenvio                 COLUMN-LABEL "Data de Envio"
            WITH 4 DOWN NO-BOX OVERLAY.    

FORM      b_emficha HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH WIDTH 48 ROW 12 CENTERED NO-BOX OVERLAY FRAME f_financeiro.


/**** Browser referente a opcao "D" ****/
DEF BROWSE b_dadosfn QUERY q_dadosfn   
    DISPLAY cratsfn.cddbanco                 COLUMN-LABEL "Bco"
            cratsfn.cdageban                 COLUMN-LABEL "Age."
            cratsfn.nrdconta                 COLUMN-LABEL "Conta"
            cratsfn.dgdconta                 COLUMN-LABEL "DV"
            cratsfn.dtabtcct                 COLUMN-LABEL "Abertura"
            cratsfn.nminsfin  FORMAT "x(20)" COLUMN-LABEL "Inst.Fin." 
            WITH 4 DOWN NO-BOX OVERLAY .

FORM      b_dadosfn HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH WIDTH 60 ROW 12 NO-BOX CENTERED OVERLAY FRAME f_dadosfn.

FORM SKIP(7)
     reg_dsdopcao[1]  AT 12 NO-LABEL                        FORMAT "x(7)"
     reg_dsdopcao[2]  AT 27 NO-LABEL                        FORMAT "x(7)"
     reg_dsdopcao[3]  AT 42 NO-LABEL                        FORMAT "x(8)"
     WITH ROW 11 WIDTH 62 OVERLAY SIDE-LABELS CENTERED 
     FRAME f_regua.


/*--- FORM'S DA TELA ---*/
FORM SKIP(1)
     tel_desopcao AT  5 LABEL "Opcao"
          HELP "Digite D(Dados Sistema Financeiro)/ E(Emissao Ficha Cadastral)"
     SKIP(1)
     tel_nrcpfcgc AT  7 LABEL "C.P.F./C.N.P.J."
     tel_inpessoa AT 43 LABEL "Tipo de Pessoa"
     SKIP
     tel_nmextttl AT 11 LABEL "Nome"
     WITH ROW 5 OVERLAY SIZE 78 BY 17 CENTERED NO-LABELS SIDE-LABELS
          TITLE "SISTEMA FINANCEIRO NACIONAL" FRAME f_contas.

FORM SKIP(2)
     "INSTITUICAO DESTINATARIA"  AT 28
     SKIP(2)
     tel_cddbanco AT 14 LABEL "Codigo Banco"
              HELP "Informe o codigo da instituicao"
     tel_nmextbcc AT 35
     SKIP(1)
     tel_cdageban AT 12 LABEL "Codigo Agencia"
              HELP "Informe a codigo da agencia (sem DV)"
     tel_nmageban AT 36
     SKIP(3)
     WITH NO-BOX OVERLAY ROW 10 COLUMN 3 NO-LABELS SIDE-LABELS FRAME f_dadose.
                                           
FORM SKIP(1)
     tel_dtabtcct AT  3 LABEL "Abertura C/C"
                        HELP "Informe a data de abertura da conta"
     SKIP(1)
     tel_cddbanco AT  5 LABEL "Cod. Banco"
              HELP "Informe o codigo do banco ou 0(zero) para inst. financeira"
              VALIDATE (INPUT tel_cddbanco > 0 ,
                              "Informe o banco.")
     tel_nmextbcc AT 24
     SKIP(1)
     tel_cdageban AT  2 LABEL "Agencia Banco"
                        HELP "Informe a codigo da agencia (sem DV)"
     tel_nmageban FORMAT "x(20)" AT 24
   
     tel_nrdctasf AT 45 LABEL "Conta C/C"
                        HELP "Informe o numero da conta corrente (sem DV)"
                        tel_dgdconta AT 67 LABEL "DV"
                        HELP "Informe o Digito Verificador da conta corrente"
     SKIP(1)
     tel_nminsfin AT  4 LABEL "Nome Instituicao Financeira"
                        HELP "Informe o nome da instituicao financeira"
     SKIP(2)
     WITH OVERLAY ROW 11 COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS FRAME f_dados.


FORM SKIP(1)
     SPACE(6)
     tel_tpimpres[1] FORMAT "x(15)"
                     HELP "Pressione ENTER para imprimir / F4 para sair"
     SPACE(7)
     SKIP(1)
     WITH OVERLAY CENTERED NO-LABELS ROW 12
          TITLE " Imprimir " FRAME f_impres.


/**** Brwose da opcao "E"  ****/
ON ANY-KEY OF b_emficha  IN FRAME f_financeiro  DO:

   HIDE MESSAGE NO-PAUSE.

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.

            IF   reg_contador > 3   THEN
                 reg_contador = 1.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 3.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
           ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
           
           IF   AVAILABLE cratsfn   THEN
                DO:
                    ASSIGN 
                        aux_nrdrowid = cratsfn.nrdrowid
                        aux_dtmvtosf = cratsfn.dtmvtolt
                        aux_dtdenvio = cratsfn.dtdenvio
                        aux_nrseqdig = cratsfn.nrseqdig
                        aux_nrdlinha = CURRENT-RESULT-ROW("q_emficha").
                         
                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b_emficha:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN 
                    aux_nrdrowid = ?
                    aux_dtmvtosf = ?
                    aux_dtdenvio = ?
                    aux_nrseqdig = 0
                    aux_nrdlinha = 0.

           IF  glb_cddopcao = "P" THEN
               DO:
                   RUN imprimir_ficha ( INPUT 2 ).

                   IF  RETURN-VALUE = "NOK"  THEN
                       RETURN NO-APPLY.
               END.
   
           IF  glb_cddopcao = "I" THEN
               RUN inclui_sfn_emissao.
   
           IF  glb_cddopcao = "E" AND aux_nrdrowid <> ? THEN
               DO:
                   RUN exclui_sfn_emissao.

                   IF  RETURN-VALUE = "NOK"  THEN
                       DO:
                           RETURN NO-APPLY.
                       END.
               END.

           ASSIGN 
               aux_nrdrowid = ?
               aux_dtmvtosf = ?
               aux_dtdenvio = ?
               aux_nrseqdig = 0
               glb_cddopcao = "C".
           
           RUN Busca_Dados ( INPUT 2 ).

           OPEN QUERY q_dadosfn FOR EACH cratsfn 
                                   WHERE cratsfn.cdcooper = glb_cdcooper 
                                         NO-LOCK BY cratsfn.nrseqdig.

           APPLY "GO".
           HIDE FRAME f_dadose NO-PAUSE.

        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
END.

/**** Browser da opcao "D"  ****/
ON ANY-KEY OF b_dadosfn  IN FRAME f_dadosfn  DO:

   HIDE MESSAGE NO-PAUSE.

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.

            IF   reg_contador > 3   THEN
                 reg_contador = 1.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 3.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
           ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].

           IF   AVAILABLE cratsfn   THEN
                DO:
                    ASSIGN 
                        aux_nrdrowid = cratsfn.nrdrowid
                        aux_dtmvtosf = cratsfn.dtmvtolt
                        aux_dtdenvio = cratsfn.dtdenvio
                        aux_nrseqdig = cratsfn.nrseqdig
                        aux_nrdlinha = CURRENT-RESULT-ROW("q_dadosfn").
                         
                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b_dadosfn:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrdlinha = 0.
              
           IF  glb_cddopcao = "A" AND aux_nrdrowid <> ? THEN
               RUN altera_sfn_dados. 
   
           IF  glb_cddopcao = "I" THEN
               RUN inclui_sfn_dados. 
   
           IF  glb_cddopcao = "E" AND aux_nrdrowid <> ? THEN
               DO:
                   RUN exclui_sfn_dados.
                   
                   IF  RETURN-VALUE = "NOK"  THEN
                       DO:
                           RETURN NO-APPLY.
                       END.
               END.


           ASSIGN 
               aux_nrdrowid = ?
               aux_dtmvtosf = ?
               aux_dtdenvio = ?
               aux_nrseqdig = 0
               glb_cddopcao = "C".

           RUN Busca_Dados ( INPUT 1 ).

           OPEN QUERY q_dadosfn FOR EACH cratsfn 
                                   WHERE cratsfn.cdcooper = glb_cdcooper 
                                         NO-LOCK BY cratsfn.nrseqdig.

           APPLY "GO".
           HIDE FRAME f_dados.

        END.
   ELSE
        RETURN.
        
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0061) THEN
       RUN sistema/generico/procedures/b1wgen0061.p 
           PERSISTENT SET h-b1wgen0061.

   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.

   ASSIGN tel_dtabtcct = ?
          tel_cddbanco = 0
          tel_cdageban = 0
          tel_nrdctasf = 0
          tel_dgdconta = ""
          tel_nminsfin = ""
          tel_nmagenci = ""
          shr_idseqttl = tel_idseqttl
          aux_dtmvtosf = ?
          aux_dtdenvio = ?
          aux_nrseqdig = 0
          glb_cddopcao = "C".

   RUN Busca_Dados ( INPUT 0 ).

   IF  RETURN-VALUE <> "OK" THEN
       NEXT.

   RUN Atualiza_Tela ( INPUT 0 ).  

   IF  RETURN-VALUE <> "OK" THEN
       NEXT.
                                           
   ASSIGN tel_desopcao = TRUE.
    
   DISPLAY tel_nrcpfcgc
           tel_inpessoa
           tel_nmextttl 
           WITH FRAME f_contas.
               
   UPDATE tel_desopcao WITH FRAME f_contas.

   IF   tel_desopcao = TRUE   THEN   /* DADOS */
        DO:
           
            ASSIGN  reg_contador = 2  
                    aux_contador = 2  
                    glb_cddopcao = "I".
                  
            DO  WHILE TRUE :
                
                CLEAR FRAME f_dados. 
                       
                ASSIGN   aux_contador =  reg_contador
                         tel_cddbanco =  0 
                         tel_cdageban =  0
                         reg_cddopcao[3] = "A"
                         reg_dsdopcao[3] = "Alterar"
                         aux_nrseqdig    = 0.
                
                DISPLAY reg_dsdopcao WITH FRAME f_regua.
             
                /* Somente para marcar a opcao escolhida */
               
                CHOOSE FIELD reg_dsdopcao[aux_contador] PAUSE 0
                                                        WITH FRAME f_regua. 

                RUN Busca_Dados ( INPUT 1 ).

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE.
                 
                OPEN QUERY q_dadosfn FOR EACH cratsfn
                                         WHERE cratsfn.cdcooper = glb_cdcooper
                                               NO-LOCK BY cratsfn.nrseqdig.

                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                    IF   aux_nrdlinha > 0   THEN
                         REPOSITION q_dadosfn TO ROW(aux_nrdlinha).
                      
                    UPDATE b_dadosfn WITH FRAME f_dadosfn.   
                    LEAVE.                                  
                END.

                IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                    LEAVE.
                           
            END. /** fim do WHILE TRUE **/
      
        END.
   ELSE         /* IMPRESSOES - FICHA / DESCTO DE CHQS / EXTRATO DE EMP. */
        DO:
              
            ASSIGN  reg_contador = 2  
                    aux_contador = 2  
                    glb_cddopcao = "I".
                  
            DO  WHILE TRUE :
                
                CLEAR FRAME f_dadose. 
                       
                ASSIGN   aux_contador =  reg_contador
                         tel_cddbanco =  0 
                         tel_cdageban =  0
                         reg_cddopcao[3] = "P"
                         reg_dsdopcao[3] = "Imprimir". 
                
                DISPLAY reg_dsdopcao WITH FRAME f_regua.
            
                /* Somente para marcar a opcao escolhida */

                CHOOSE FIELD reg_dsdopcao[aux_contador] PAUSE 0
                                                        WITH FRAME f_regua. 

                RUN Busca_Dados ( INPUT 2 ).

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE.
                                 
                OPEN QUERY q_emficha FOR EACH cratsfn 
                                         WHERE cratsfn.cdcooper = glb_cdcooper
                                               NO-LOCK BY cratsfn.nrseqdig.

                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    IF   aux_nrdlinha > 0   THEN
                         REPOSITION q_emficha TO ROW(aux_nrdlinha).

                     UPDATE b_emficha WITH FRAME f_financeiro.
                     LEAVE.
                END.
            
                IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                     LEAVE.
                           
            END. /** fim do WHILE TRUE **/
        END.

END.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE OBJECT h-b1wgen0060.

IF  VALID-HANDLE(h-b1wgen0061) THEN
    DELETE OBJECT h-b1wgen0061.

HIDE FRAME f_contas NO-PAUSE.
HIDE FRAME f_dados  NO-PAUSE.
HIDE FRAME f_contas_fisica   NO-PAUSE.
HIDE FRAME f_contas_juridica NO-PAUSE.

PROCEDURE inclui_sfn_dados:    

    ASSIGN tel_dtabtcct = ?
           tel_nrdctasf = 0
           tel_dgdconta = ""
           tel_nminsfin = ""
           tel_cddbanco = 0
           tel_nmextbcc = ""
           tel_cdageban = 0
           tel_nmageban = ""
           tel_nrdctasf = 0
           tel_dgdconta = "".

    Inclui: REPEAT:

        UPDATE tel_dtabtcct
               tel_cddbanco
               WITH FRAME f_dados.

        IF   tel_cddbanco = 0   THEN
             DO:
                 ASSIGN tel_cdageban = 0
                        tel_nrdctasf = 0
                        tel_dgdconta = "".

                 DISPLAY tel_cdageban
                         tel_nrdctasf
                         tel_dgdconta
                         WITH FRAME f_dados.

                 UPDATE tel_nminsfin WITH FRAME f_dados.
             END.
        ELSE
             DO:
                 ASSIGN tel_nminsfin = "".
                 DISPLAY tel_nminsfin WITH FRAME f_dados.

                 DYNAMIC-FUNCTION("BuscaBanco" IN h-b1wgen0060,
                                  INPUT tel_cddbanco,
                                  OUTPUT tel_nmextbcc,
                                  OUTPUT glb_dscritic).

                 IF  glb_dscritic <> "" THEN
                     DO:
                        MESSAGE glb_dscritic.
                        NEXT.
                     END.

                 DISPLAY tel_nmextbcc 
                         WITH FRAME f_dados.

                 UPDATE  tel_cdageban WITH FRAME f_dados.

                 DYNAMIC-FUNCTION("BuscaAgencia" IN h-b1wgen0060,
                                   INPUT tel_cddbanco,
                                   INPUT tel_cdageban,
                                  OUTPUT tel_nmageban,
                                  OUTPUT glb_dscritic).

                 IF  glb_dscritic <> "" THEN
                     DO:
                        MESSAGE glb_dscritic.
                        NEXT.
                     END.

                 DISPLAY tel_nmageban 
                         WITH FRAME f_dados.

                 UPDATE  tel_nrdctasf
                         tel_dgdconta
                         WITH FRAME f_dados.
             END.

        RUN Valida_Dados ( INPUT 1 ). /* tpregist */

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        RUN Grava_Dados ( INPUT 1 ). /* tpregist */

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        LEAVE Inclui.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE exclui_sfn_dados:

    RUN Busca_Dados ( INPUT 1 ).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RUN Valida_Dados ( INPUT 1 ). /* tpregist */

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RUN Confirma.

    IF  aux_confirma <> "S" THEN
        RETURN "OK".

    RUN Exclui_Dados ( INPUT 1 ). /* tpregist */

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE altera_sfn_dados:

    Altera: REPEAT:

        RUN Busca_Dados ( INPUT 1 ).

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        RUN Atualiza_Tela ( INPUT 1 ).

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        DISPLAY  tel_dtabtcct 
                 tel_cddbanco  
                 tel_nmextbcc
                 tel_cdageban          
                 tel_nmageban 
                 tel_nrdctasf
                 tel_dgdconta 
                 tel_nminsfin
                 WITH FRAME f_dados.

        UPDATE tel_dtabtcct
               tel_cddbanco
               WITH FRAME f_dados.

        IF  tel_cddbanco = 0   THEN
            DO:
                ASSIGN tel_nmextbcc = ""
                       tel_cdageban = 0
                       tel_nmageban = ""
                       tel_nrdctasf = 0
                       tel_dgdconta = "".

                DISPLAY tel_nmextbcc
                        tel_cdageban
                        tel_nmageban
                        tel_nrdctasf
                        tel_dgdconta
                        WITH FRAME f_dados.

                UPDATE tel_nminsfin WITH FRAME f_dados.
            END.
        ELSE
            DO:
               ASSIGN tel_nminsfin = "".
               DISPLAY tel_nminsfin WITH FRAME f_dados.

               DYNAMIC-FUNCTION("BuscaBanco" IN h-b1wgen0060,
                                INPUT tel_cddbanco,
                                OUTPUT tel_nmextbcc,
                                OUTPUT glb_dscritic).

               IF  glb_dscritic <> "" THEN
                   DO:
                      MESSAGE glb_dscritic.
                      NEXT.
                   END.

               DISPLAY tel_nmextbcc 
                       WITH FRAME f_dados.

               UPDATE  tel_cdageban WITH FRAME f_dados.

               DYNAMIC-FUNCTION("BuscaAgencia" IN h-b1wgen0060,
                                 INPUT tel_cddbanco,
                                 INPUT tel_cdageban,
                                OUTPUT tel_nmageban,
                                OUTPUT glb_dscritic).

               IF  glb_dscritic <> "" THEN
                   DO:
                      MESSAGE glb_dscritic.
                      NEXT.
                   END.

               DISPLAY tel_nmageban 
                       WITH FRAME f_dados.

               UPDATE  tel_nrdctasf
                       tel_dgdconta
                       WITH FRAME f_dados.
            END.

        RUN Valida_Dados ( INPUT 1 ). /* tpregist */

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        RUN Grava_Dados ( INPUT 1 ). /* tpregist */

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        LEAVE Altera.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE inclui_sfn_emissao:

    Inclui: REPEAT:
        
        UPDATE tel_cddbanco WITH FRAME f_dadose.

        DYNAMIC-FUNCTION("BuscaBanco" IN h-b1wgen0060,
                         INPUT tel_cddbanco,
                         OUTPUT tel_nmextbcc,
                         OUTPUT glb_dscritic).

        IF  glb_dscritic <> "" THEN
            DO:
               MESSAGE glb_dscritic.
               NEXT.
            END.

        DISPLAY tel_nmextbcc 
                WITH FRAME f_dadose.

        UPDATE  tel_cdageban WITH FRAME f_dadose.

        DYNAMIC-FUNCTION("BuscaAgencia" IN h-b1wgen0060,
                          INPUT tel_cddbanco,
                          INPUT tel_cdageban,
                         OUTPUT tel_nmageban,
                         OUTPUT glb_dscritic).

        IF  glb_dscritic <> "" THEN
            DO:
               MESSAGE glb_dscritic.
               NEXT.
            END.

        DISPLAY tel_nmageban 
                WITH FRAME f_dadose.

        RUN Valida_Dados ( INPUT 2 ). /* tpregist */

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        RUN Grava_Dados ( INPUT 2 ). /* tpregist */

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        LEAVE Inclui.
    END.

    RETURN "OK". 

END PROCEDURE.

PROCEDURE exclui_sfn_emissao:

    RUN Busca_Dados ( INPUT 2 ).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RUN Valida_Dados ( INPUT 2 ). /* tpregist */

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RUN Confirma.

    IF  aux_confirma <> "S" THEN
        RETURN "OK".

    RUN Exclui_Dados ( INPUT 2 ). /* tpregist */

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE imprimir_ficha:

    DEFINE INPUT  PARAMETER par_tpregist AS INTEGER     NO-UNDO.

    /*--- FORM'S DAS IMPRESSOES ---*/
    FORM SKIP(14)
         tt-fichacad.dsdcabec NO-LABEL FORMAT "X(60)"     AT 6 SKIP(3)
         "\022\024\033\120"     /* Reseta impressora */
         "\033\105"
         "FORNECIMENTO DA DATA DE INICIO DO RELACIONAMENTO DO CLIENTE" AT 6
         SKIP(1) "RESOLUCAO 3279/BACEN"                   AT 27
         "\033\106"                                             SKIP(3)
         "PESSOA FISICA"                                  AT 32 SKIP(2)
         "INST.DETENTORA.....:"                           AT 7
         tt-fichacad.cdinsdet NO-LABEL
         " - "
         tt-fichacad.nmrescop NO-LABEL                          SKIP(1)
         "AGENC.DETENTORA....:"                           AT 7 
         tt-fichacad.cdagedet                                   SKIP(1)
         tt-fichacad.cddbanco LABEL "INST. DESTINATARIA." AT 7
         "-"
         tt-fichacad.nmdbanco NO-LABEL                          SKIP(1)
         tt-fichacad.cdageban LABEL "AGENC. DESTINATARIA" AT 7
         "-"
         tt-fichacad.nmageban NO-LABEL                          SKIP(1)
         tt-fichacad.nmprimtl LABEL "NOME..............." AT 7  SKIP(1)
         tt-fichacad.nmsegntl LABEL "SEGUNDO TITULAR...." AT 7  SKIP(1)
         tt-fichacad.nrcpfcgc LABEL "CPF................" AT 7  SKIP(1)
         tt-fichacad.nrcpfstl LABEL "CPF SEG.TITULAR...." AT 7
         WITH WIDTH 80 COLUMN 6 NO-BOX NO-LABELS SIDE-LABELS 
         FRAME f_ficha_fisica.

    FORM SKIP(14)
         tt-fichacad.dsdcabec NO-LABEL                       AT 6  SKIP(3)
         "\022\024\033\120"     /* Reseta impressora */
         "\033\105"
         "FORNECIMENTO DA DATA DE INICIO DO RELACIONAMENTO DO CLIENTE" AT 6
         SKIP(1) "RESOLUCAO 3279/BACEN"                      AT 27 
          "\033\106"                                               SKIP(3)
         "PESSOA JURIDICA"                                   AT 30 SKIP(2)
         "INST.DETENTORA.....:"                              AT 7
         tt-fichacad.cdinsdet NO-LABEL
         " - "
         tt-fichacad.nmrescop NO-LABEL                             SKIP(1)
         "AGENC.DETENTORA....:"                              AT 7  
         tt-fichacad.cdagedet                                      SKIP(1)
         tt-fichacad.cddbanco LABEL "INST. DESTINATARIA."    AT 7
         "-"
         tt-fichacad.nmdbanco NO-LABEL                             SKIP(1)
         tt-fichacad.cdageban LABEL "AGENC. DESTINATARIA"    AT 7
         "-"
         tt-fichacad.nmageban NO-LABEL                             SKIP(1)
         tt-fichacad.nmprimtl LABEL "RAZAO SOCIAL......."    AT 7  SKIP(1)
         tt-fichacad.nrcpfcgc LABEL "CNPJ..............."    AT 7
         WITH WIDTH 80 COLUMN 6 NO-BOX NO-LABELS SIDE-LABELS 
              FRAME f_ficha_juridica.

    FORM SKIP(1)
         tt-fichacad.dtabtcct LABEL "ABERTURA DA C/C...."    
         SKIP(1)
         tt-fichacad.dssitdct LABEL "SITUACAO DA C/C...."    
         SKIP(1)
         tt-fichacad.dsdemiss LABEL "DATA ENCERRAMENTO.."      
         SKIP(7)
         "AUTORIZO O ENVIO DAS INFORMACOES AO BANCO DESTINATARIO:"  
         SKIP(8)
         "_________________________"  
         "_________________________"  AT 34
         SKIP
         tt-fichacad.nmextttl FORMAT "X(25)"       
         tt-fichacad.nmresbr1 FORMAT "X(35)" AT 34
         SKIP
         tt-fichacad.nmresbr2 FORMAT "X(35)" AT 34
         WITH WIDTH 80 COLUMN 12 NO-BOX NO-LABELS SIDE-LABELS FRAME f_ficha.

    RUN Busca_Impressao IN h-b1wgen0061
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT aux_nrcpfcgc,
          INPUT par_tpregist,
          INPUT aux_nrseqdig,
          INPUT glb_dtmvtolt,
         OUTPUT TABLE tt-fichacad,
         OUTPUT TABLE tt-erro ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    FIND FIRST tt-fichacad NO-ERROR.

    IF  NOT AVAILABLE tt-fichacad THEN
        RETURN "NOK".

    PAUSE 1 NO-MESSAGE.

    DISPLAY tel_tpimpres WITH FRAME f_impres.
    CHOOSE FIELD tel_tpimpres[1]
                 WITH FRAME f_impres.
            
    aux_frameval = FRAME-VALUE.
                 
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.      
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    UNIX SILENT VALUE("rm rl/" + aux_nmendter + 
                      "* 2> /dev/null").
    aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
                    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED  PAGE-SIZE 84.

    /* pessoa fisica */
    IF   aux_inpessoa = 1   THEN
         DO:
             DISPLAY STREAM str_1 tt-fichacad.dsdcabec
                                  tt-fichacad.cdagedet
                                  tt-fichacad.nmrescop
                                  tt-fichacad.cddbanco
                                  tt-fichacad.nmdbanco   
                                  tt-fichacad.cdageban
                                  tt-fichacad.nmageban
                                  tt-fichacad.nmprimtl
                                  tt-fichacad.nmsegntl
                                  tt-fichacad.nrcpfcgc
                                  tt-fichacad.nrcpfstl
                                  tt-fichacad.cdinsdet
                                  WITH FRAME f_ficha_fisica.
         END.
    ELSE   /* pessoa juridica */
         DO:
             DISPLAY STREAM str_1 tt-fichacad.dsdcabec
                                  tt-fichacad.cdagedet
                                  tt-fichacad.nmrescop
                                  tt-fichacad.cddbanco
                                  tt-fichacad.nmdbanco   
                                  tt-fichacad.cdageban
                                  tt-fichacad.nmageban
                                  tt-fichacad.nmprimtl
                                  tt-fichacad.nrcpfcgc
                                  tt-fichacad.cdinsdet
                                  WITH FRAME f_ficha_juridica.
         END.

    DISPLAY STREAM str_1 tt-fichacad.dtabtcct
                         tt-fichacad.dssitdct
                         tt-fichacad.dsdemiss
                         tt-fichacad.nmextttl  
                         tt-fichacad.nmresbr1
                         tt-fichacad.nmresbr2
                         WITH FRAME f_ficha.
            
    OUTPUT STREAM str_1 CLOSE.

    /* alerta sobre papel timbrado */
    HIDE MESSAGE NO-PAUSE.
    MESSAGE "ATENCAO!!! Impressao de FICHA CADASTRAL!".
    MESSAGE "Coloque 1 folha de papel TIMBRADO na impressora.".
    PAUSE.

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = tel_nrdconta 
                       NO-LOCK NO-ERROR.
                 
    glb_nmformul = "80col".
    glb_nrdevias = 3.   
    { includes/impressao.i }

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Dados:

    DEFINE INPUT  PARAMETER par_tpregist AS INTEGER     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0061) THEN
        RUN sistema/generico/procedures/b1wgen0061.p 
            PERSISTENT SET h-b1wgen0061.

    RUN Busca_Dados IN h-b1wgen0061
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
          INPUT aux_nrdrowid,
          INPUT glb_dtmvtolt,
          INPUT par_tpregist,
          INPUT aux_nrseqdig,
          INPUT glb_dsdepart,
         OUTPUT TABLE tt-dadoscf,
         OUTPUT TABLE tt-crapsfn,
         OUTPUT TABLE tt-erro ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    EMPTY TEMP-TABLE cratsfn.

    FOR EACH tt-crapsfn WHERE tt-crapsfn.cdcooper = glb_cdcooper
                              NO-LOCK:
        CREATE cratsfn.
        BUFFER-COPY tt-crapsfn TO cratsfn.
    END.

    RETURN "OK".
END.

PROCEDURE Valida_Dados:

    DEFINE INPUT  PARAMETER par_tpregist AS INTEGER     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0061) THEN
        RUN sistema/generico/procedures/b1wgen0061.p 
            PERSISTENT SET h-b1wgen0061.
                            
    RUN Valida_Dados IN h-b1wgen0061
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao, /* I/A/E */
          INPUT tel_desopcao, /* D/E */
          INPUT aux_nrcpfcgc,
          INPUT par_tpregist,
          INPUT aux_nrseqdig,
          INPUT tel_cddbanco,
          INPUT tel_cdageban,
          INPUT tel_dtabtcct,
          INPUT tel_nrdctasf,
          INPUT CAPS(tel_dgdconta),
          INPUT CAPS(tel_nminsfin),
          INPUT aux_dtmvtosf,
          INPUT glb_dtmvtolt,
          INPUT glb_dsdepart,
          INPUT aux_dtdenvio,
         OUTPUT TABLE tt-erro) NO-ERROR.

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

    RETURN "OK".
END.

PROCEDURE Grava_Dados:

    DEFINE INPUT  PARAMETER par_tpregist AS INTEGER     NO-UNDO.

    IF  VALID-HANDLE(h-b1wgen0061) THEN
        DELETE OBJECT h-b1wgen0061.

    RUN sistema/generico/procedures/b1wgen0061.p PERSISTENT SET h-b1wgen0061.

    RUN Grava_Dados IN h-b1wgen0061
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao, /* I/A/E */
          INPUT tel_desopcao, /* D/E */
          INPUT aux_nrcpfcgc,
          INPUT par_tpregist,
          INPUT aux_nrseqdig,
          INPUT glb_dtmvtolt,
          INPUT tel_cddbanco,
          INPUT tel_cdageban,
          INPUT tel_dtabtcct,
          INPUT tel_nrdctasf,
          INPUT CAPS(tel_dgdconta),
          INPUT CAPS(tel_nminsfin),
         OUTPUT TABLE tt-erro) NO-ERROR.

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

    IF  VALID-HANDLE(h-b1wgen0061) THEN
        DELETE OBJECT h-b1wgen0061.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Exclui_Dados:

    DEFINE INPUT  PARAMETER par_tpregist AS INTEGER     NO-UNDO.

    IF  VALID-HANDLE(h-b1wgen0061) THEN
        DELETE OBJECT h-b1wgen0061.

    RUN sistema/generico/procedures/b1wgen0061.p PERSISTENT SET h-b1wgen0061.

    RUN Exclui_Dados IN h-b1wgen0061
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT tel_desopcao, /* D/E */
          INPUT aux_nrcpfcgc,
          INPUT par_tpregist,
          INPUT aux_nrseqdig,
          INPUT glb_dtmvtolt,
          INPUT aux_dtmvtosf,
          INPUT aux_dtdenvio,
         OUTPUT TABLE tt-erro) NO-ERROR.

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

    IF  VALID-HANDLE(h-b1wgen0061) THEN
        DELETE OBJECT h-b1wgen0061.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza_Tela:

    DEFINE INPUT  PARAMETER par_tpregist AS INTEGER     NO-UNDO.

    FIND FIRST tt-dadoscf NO-ERROR.

    IF  AVAILABLE tt-dadoscf THEN
        DO:
           ASSIGN
                aux_nrcpfcgc = tt-dadoscf.nrcpfcgc
                tel_nmextttl = tt-dadoscf.nmextttl
                aux_cdagenci = tt-dadoscf.cdagenci
                aux_inpessoa = tt-dadoscf.inpessoa.

           /* Tratamento de CPF/CGC */
           IF  tt-dadoscf.inpessoa = 1 THEN
               ASSIGN
                   tel_inpessoa = "1 - FISICA"
                   tel_nrcpfcgc = STRING(STRING(aux_nrcpfcgc,"zzzzzzzzzzz"),
                                            "xxx.xxx.xxx-xx").
           ELSE
               ASSIGN 
                   tel_inpessoa = "2 - JURIDICA"
                   tel_nrcpfcgc = STRING(STRING(aux_nrcpfcgc,"zzzzzzzzzzzzzz"),
                                         "xx.xxx.xxx/xxxx-xx").

           FIND FIRST tt-crapsfn WHERE tt-crapsfn.cdcooper = glb_cdcooper AND
                                       tt-crapsfn.nrcpfcgc = aux_nrcpfcgc AND
                                       tt-crapsfn.tpregist = par_tpregist AND
                                       tt-crapsfn.nrseqdig = aux_nrseqdig 
                                       NO-ERROR.

           IF  AVAILABLE tt-crapsfn THEN
               DO:
                  ASSIGN 
                      tel_dtabtcct = tt-crapsfn.dtabtcct
                      tel_cddbanco = tt-crapsfn.cddbanco
                      tel_cdageban = tt-crapsfn.cdageban
                      tel_nrdctasf = tt-crapsfn.nrdctasf
                      tel_dgdconta = tt-crapsfn.dgdconta
                      tel_nminsfin = tt-crapsfn.nminsfin
                      tel_nmextbcc = tt-crapsfn.nmdbanco
                      tel_nmageban = tt-crapsfn.nmageban.
               END.
        END.
    ELSE 
        DO:
           ASSIGN 
               tel_dtabtcct = ?
               tel_cddbanco = 0
               tel_cdageban = 0
               tel_nrdctasf = 0
               tel_dgdconta = ""
               tel_nminsfin = ""
               tel_nmextbcc = ""
               tel_nmageban = "".
        END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE confirma.

   /* Confirma */
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         ASSIGN aux_confirma = "N"
         glb_cdcritic = 78.
         RUN fontes/critic.p.
         glb_cdcritic = 0.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         LEAVE.
      END.  /*  Fim do DO WHILE TRUE  */
      
     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
          DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             MESSAGE glb_dscritic.
             PAUSE 2 NO-MESSAGE.
          END. /* Mensagem de confirmacao */
                                
END PROCEDURE.

/* ......................................................................... */
