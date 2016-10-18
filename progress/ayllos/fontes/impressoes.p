/* .............................................................................

   Programa: fontes/impressoes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2006                      Ultima Atualizacao: 09/09/2016

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Menu de impressoes da tela CONTA.

   Alteracoes: 14/11/2006 - Imprime sempre o mesmo faturamento bruto (Magui). 
   
               11/12/2006 - Acerto no crapalt.fglctitg (Ze).

               18/12/2006 - Liberado novo termo(Mirtes).
               
               19/12/2006 - Efetuado acerto na rotina p_abertura_nova, e
                            corrigido erro na execucao da rotina p_financas
                            (Diego).
               
               28/12/2006 - Alterado texto e incluido campos para assinatura 
                            dos titulares pessoa fisica e juridica (Elton).
                            
               15/01/2007 - Efetuadas modificacoes no Termo de Conhecimento
                            (Diego).
                            
               21/02/2007 - Efetuado tratamento para impressao do termo BANCOOB
                            e termo ITG (Diego).

               11/01/2008 - Correcao de gramatica no Termo de Conhecimento
                            (David).
                            
               11/11/2009 - Ajuste para o novo Termo de Adesao - retirar o 
                            antigo Termo CI e Termo BANCCOB (Fernando). 
                            
               27/04/2010 - Adaptacao para uso de BO's (Jose Luis, DB1)
                            Retirada a definicao da procedure 'p_abertura_antiga'
                            
               19/10/2010 - Realizado alteracao na cláusula C (Adriano). 
               
               04/04/2011 - Nao serao impressos, os dados do contato na ficha
                            cadastral a partir da tela CONTAS (Adriano).
                            
               06/06/2011 - Incluir mais uma linha de endereco quando pessoa
                            juridica (Gabriel)             
                            
               13/12/2012 - Ajustes de tamanho do campo extenso da cooperativa
                            (Gabriel). 
               
               28/06/2013 - Incluida opçao de Cartao Assinatura na impressao.
                            (Jean Michel).            
                            
               30/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               24/10/2013 - Ajuste opçao de Cartao Assinatura na impressao
                            completa (Jean Michel).
                            
               08/01/2014 - Aumentado o format de tt-termo-ident.dsmvtolt para 
                            80 para comportar maiores nomes de cidades e maiores
                            nomes de meses. (Carlos)
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               05/06/2014 - Ajuste em tel_idseqttl, retirado de um local que o 
                            setava como 0 quando PJ, colocando o na parte de 
                            Cartao Assin.
                            (Jorge/Rosangela) - SD 141044   
                            
               03/09/2015 - Projeto Reformulacao cadastral 
                            (Tiago Castro - RKAM). 
               
               03/02/2016 - Adicionado duas novas clausulas ao contrato conforme 
                            solicitado no chamado 388719. (Kelvin)

               09/09/2016 - Alterado procedure Busca_Dados, retorno do parametro
						   aux_qtminast referente a quantidade minima de assinatura
						   conjunta, SD 514239 (Jean Michel).
..............................................................................*/

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgen0058tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/b1wgen0062tt.i }
{ sistema/generico/includes/b1wgen0063tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF STREAM str_1.  /* Para Impressao */

DEF VAR par_flgrodar AS LOGICAL                                       NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL                                       NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                       NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                       NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                          NO-UNDO.
DEF VAR aux_qtregist AS INT                                           NO-UNDO.
DEF VAR aux_qtdprocu AS INT                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                         NO-UNDO.
DEF VAR par_criararq AS INT                                           NO-UNDO.
DEF VAR aux_qtdrespo AS INT                                           NO-UNDO.      
/*   Para Menu Principal  */
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(08)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(08)" INIT "Cancelar"        NO-UNDO.
DEF VAR tel_completa AS CHAR    FORMAT "x(08)" INIT "Completo"        NO-UNDO.
DEF VAR tel_abertura AS CHAR    FORMAT "x(08)" INIT "Abertura"        NO-UNDO.
DEF VAR tel_cadastro AS CHAR    FORMAT "x(11)" INIT "Ficha Cadas" NO-UNDO.
DEF VAR tel_fin_solt AS CHAR    FORMAT "x(10)" INIT "Financeiro"      NO-UNDO.
DEF VAR tel_termoitg AS CHAR    FORMAT "x(10)" INIT "INTEGRACAO"      NO-UNDO.
DEF VAR tel_termoban AS CHAR    FORMAT "x(10)" INIT "BANCOOB"         NO-UNDO.

DEF VAR tel_ctaassin AS CHAR    FORMAT "x(12)" INIT "Cartao Assin" NO-UNDO.

DEF VAR aux_inpessoa AS INTE                                          NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                          NO-UNDO.
DEF VAR h-b1wgen0058 AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0063 AS HANDLE                                        NO-UNDO.
DEF VAR tel_tpimpres AS LOGICAL FORMAT "BRANCO/PREENCHIDO"            NO-UNDO.

DEF VAR tel_imprtitu AS CHAR    FORMAT "x(20)" INIT "Imprimir Titular"      NO-UNDO.
DEF VAR tel_imprproc AS CHAR    FORMAT "x(23)" INIT "Imprimir Procurador"   NO-UNDO.
DEF VAR tel_imprtodo AS CHAR    FORMAT "x(14)" INIT "Imprimir Todos"        NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                                NO-UNDO.

DEF VAR par_nmendter AS CHAR                                                NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                                NO-UNDO.
DEF VAR aux_qtminast AS INTE												NO-UNDO.

DEF TEMP-TABLE cratavt    NO-UNDO LIKE tt-crapavt.
DEF TEMP-TABLE cratttl    NO-UNDO LIKE tt-crapttl.

ASSIGN glb_cdcritic = 0.
       
INPUT THROUGH basename `tty` NO-ECHO.
SET par_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

par_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      par_nmendter.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56 
              TITLE glb_nmformul FRAME f_atencao.

FORM SKIP(1) ""
     tel_completa "" 
     tel_cadastro "" 
     tel_abertura "" 
     tel_ctaassin ""
     tel_dscancel "" 
     SKIP(1)
     WITH ROW 14 COLUMN 2 NO-LABELS CENTERED OVERLAY FRAME f_imprime_pf.

FORM SKIP(1) ""
     tel_completa "" 
     tel_cadastro "" 
     tel_abertura "" 
     tel_fin_solt "" 
     tel_ctaassin ""
     tel_dscancel "" 
     SKIP(1)
     WITH ROW 14 COLUMN 2 NO-LABELS CENTERED OVERLAY FRAME f_imprime_pj.

FORM SKIP(1) ""
     tel_imprtitu "" 
     tel_imprproc ""
     tel_imprtodo ""
     SKIP(1)
     WITH ROW 14 COLUMN 2 NO-LABELS CENTERED OVERLAY FRAME f_impressaopf.

FORM SKIP(1) ""
     tel_imprproc ""
     tel_imprtodo ""
     SKIP(1)
     WITH ROW 14 COLUMN 2 NO-LABELS CENTERED OVERLAY FRAME f_impressaopj.

/* CARTAO ASSINATURA */

/* PROCURADORES */
DEF QUERY q_procuradores FOR cratavt.

DEF BROWSE b_procuradores QUERY q_procuradores
    DISPLAY cratavt.nmdavali NO-LABEL
            WITH 5 DOWN NO-BOX.

FORM b_procuradores
     WITH ROW 10 NO-LABELS CENTERED OVERLAY FRAME f_procurador.
/* FIM PROCURADORES */

/* TITULARES */
DEF QUERY q_titulares FOR cratttl.

DEF BROWSE b_titulares QUERY q_titulares
    DISPLAY cratttl.nmextttl NO-LABEL
            WITH 5 DOWN NO-BOX.

FORM b_titulares
     WITH ROW 10 NO-LABELS CENTERED OVERLAY FRAME f_titulares.
/* FIM TITULARES */


/* IMPRIME PROCURADORES */
ON RETURN OF b_procuradores IN FRAM f_procurador DO:
   
    IF NOT AVAILABLE cratavt THEN
        DO:
            MESSAGE "Procurador nao encontrado!".
            PAUSE(3) NO-MESSAGE.
            RETURN "NOK".
        END.
        
    FORM "Aguarde... Imprimindo Cartao Assinatura."
    WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

    VIEW FRAME f_aguarde.
    PAUSE 2 NO-MESSAGE.
    HIDE FRAME f_aguarde NO-PAUSE.

   IF  NOT VALID-HANDLE(h-b1wgen0063) THEN
        RUN sistema/generico/procedures/b1wgen0063.p 
            PERSISTENT SET h-b1wgen0063.
    
   RUN Imprime_Assinatura IN h-b1wgen0063(
                          INPUT glb_cdcooper,          /*cdcooper*/
                          INPUT glb_cdagenci,          /*cdagenci*/
                          INPUT 0,                     /*nrdcaixa*/
                          INPUT glb_cdoperad,          /*cdoperad*/
                          INPUT glb_nmdatela,          /*nmdatela*/
                          INPUT 1,                     /*idorigem*/
                          INPUT glb_cddopcao,          /*cddopcao*/
                          INPUT glb_dtmvtolt,          /*dtmvtolt*/
                          INPUT tel_nrdconta,          /*nrdconta*/
                          INPUT cratavt.cddconta,      /*nrdctato*/
                          INPUT tel_idseqttl,          /*idseqttl*/
                          INPUT 2,                     /*tppessoa*/ 
                          INPUT cratavt.cdcpfcgc,      /*nrcpfcgc*/
                          INPUT par_nmendter,          /*nmendter*/
                         OUTPUT par_nmarqimp,          /*nmarqimp*/
                         OUTPUT TABLE tt-erro).
    
   IF VALID-HANDLE(h-b1wgen0063) THEN
        DELETE PROCEDURE h-b1wgen0063.

   IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE(3) NO-MESSAGE.
                  RETURN "NOK".
               END.
        END.

   aux_nmarqimp = par_nmarqimp.
   CLEAR FRAME f_procurador.
   HIDE FRAME f_procurador.
   APPLY "GO".

END.
/* FIM IMPRIME PROCURADORES */

/* IMPRIME TITULARES */
ON RETURN OF b_titulares IN FRAM f_titulares DO:  
   
   FORM "Aguarde... Imprimindo Cartao Assinatura."
   WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.
    
   VIEW FRAME f_aguarde.
   PAUSE 2 NO-MESSAGE.
   HIDE FRAME f_aguarde NO-PAUSE.
  
   IF  NOT VALID-HANDLE(h-b1wgen0063) THEN
        RUN sistema/generico/procedures/b1wgen0063.p 
            PERSISTENT SET h-b1wgen0063.
   
   RUN Imprime_Assinatura IN h-b1wgen0063(
                          INPUT glb_cdcooper,     /*cdcooper*/
                          INPUT glb_cdagenci,     /*cdagenci*/
                          INPUT 0,                /*nrdcaixa*/
                          INPUT glb_cdoperad,     /*cdoperad*/
                          INPUT glb_nmdatela,     /*nmdatela*/
                          INPUT 1,                /*idorigem*/
                          INPUT glb_cddopcao,     /*cddopcao*/
                          INPUT glb_dtmvtolt,     /*dtmvtolt*/
                          INPUT tel_nrdconta,     /*nrdconta*/
                          INPUT cratttl.nrdconta, /*nrdctato*/
                          INPUT cratttl.idseqttl, /*idseqttl*/
                          INPUT 1,                /*tppessoa*/
                          INPUT 0,                /*nrcpfcgc*/
                          INPUT par_nmendter,     /*nmendter*/
                         OUTPUT par_nmarqimp,     /*nmarqimp*/
                         OUTPUT TABLE tt-erro).
   
   IF VALID-HANDLE(h-b1wgen0063) THEN
        DELETE PROCEDURE h-b1wgen0063.

   IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE(3) NO-MESSAGE.
                  RETURN "NOK".
               END.
        END.
    
   aux_nmarqimp = par_nmarqimp.
   APPLY "GO".

END.
/* FIM IMPRIME TITULARES */
/* FIM CARTAO ASSINATURA */

FUNCTION BuscaPessoa RETURNS INTEGER FORWARD.

DO WHILE TRUE:
    
   ASSIGN aux_inpessoa = BuscaPessoa().
      
    IF VALID-HANDLE(h-b1wgen0063) THEN
        DELETE PROCEDURE h-b1wgen0063.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
      IF aux_inpessoa = 1 THEN
          DO:                    /*  Pessoa Fisica  */
            DISPLAY tel_completa tel_cadastro tel_abertura  tel_ctaassin
                    tel_dscancel WITH FRAME f_imprime_pf.

            CHOOSE FIELD tel_completa  tel_cadastro  tel_abertura  tel_ctaassin
                         tel_dscancel  WITH FRAME f_imprime_pf.
          END.

      ELSE
         DO:                                             /*  Pessoa Juridica */
            /* tel_idseqttl = 0. retirado e adicionado em opcao "Cartao Assin"
                                 Jorge - 05/06/2014 */
         
            DISPLAY tel_completa  tel_cadastro  tel_abertura  tel_ctaassin  
                    tel_fin_solt  tel_dscancel  WITH FRAME f_imprime_pj.

            CHOOSE FIELD tel_completa  tel_cadastro  tel_abertura  tel_ctaassin
                        tel_fin_solt  tel_dscancel  WITH FRAME f_imprime_pj.
         END.
         
         
      aux_impcadto = FALSE.

      

      IF   FRAME-VALUE = tel_dscancel   THEN
           LEAVE.
           
      /* Pega o terminal e abre um arquivo para todos os itens */
      INPUT THROUGH basename `tty` NO-ECHO.
      SET aux_nmendter WITH FRAME f_terminal.
      INPUT CLOSE.
      
      aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                            aux_nmendter.

      UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

      ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + "_imp_comp.ex"
             glb_nmarqimp = aux_nmarqimp.
    
      IF   FRAME-VALUE = tel_completa   THEN
           DO:
               IF  NOT VALID-HANDLE(h-b1wgen0063) THEN
                           RUN sistema/generico/procedures/b1wgen0063.p 
                           PERSISTENT SET h-b1wgen0063.
                               
               RUN Imprime_Cartao_Assinatura IN h-b1wgen0063(INPUT glb_cdcooper).

               IF  RETURN-VALUE <> "NOK" THEN
                   DO:
                       
                       FORM "Aguarde... Imprimindo cartao assinatura"
                           WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_cta_assin.
                           
                       HIDE MESSAGE NO-PAUSE.
                      
                       VIEW FRAME f_aguarde_cta_assin.
                       PAUSE 2 NO-MESSAGE.
                       HIDE FRAME f_aguarde_cta_assin NO-PAUSE.
                       
                       RUN Imprime_Assinatura IN h-b1wgen0063(INPUT glb_cdcooper,  /*cdcooper*/
                                                              INPUT glb_cdagenci,  /*cdagenci*/
                                                              INPUT 0,             /*nrdcaixa*/
                                                              INPUT glb_cdoperad,  /*cdoperad*/
                                                              INPUT glb_nmdatela,  /*nmdatela*/
                                                              INPUT 1,             /*idorigem*/
                                                              INPUT glb_cddopcao,  /*cddopcao*/
                                                              INPUT glb_dtmvtolt,  /*dtmvtolt*/
                                                              INPUT tel_nrdconta,  /*nrdconta*/
                                                              INPUT 0,             /*nrdctato*/
                                                              INPUT 0,             /*idseqttl*/
                                                              INPUT 3,             /*tppessoa*/
                                                              INPUT 0,             /*nrcpfcgc*/
                                                              INPUT par_nmendter,  /*nmendter*/
                                                             OUTPUT par_nmarqimp,  /*nmarqimp*/
                                                             OUTPUT TABLE tt-erro).
               
                        
                        IF RETURN-VALUE <> "OK" THEN
                            DO:
                                FIND FIRST tt-erro NO-ERROR.

                                IF AVAILABLE tt-erro THEN
                                    DO:
                                        MESSAGE tt-erro.dscritic.
                                        PAUSE(3) NO-MESSAGE.
                                        RETURN "NOK".
                                    END.            
                            END.
                            
                        UNIX SILENT VALUE ("cat " + par_nmarqimp + " >> " + glb_nmarqimp).
                        
                        IF VALID-HANDLE(h-b1wgen0063) THEN
                            DELETE PROCEDURE h-b1wgen0063.

                   END.
               

               aux_impcadto = TRUE.
               RUN fontes/ver_ficha_cadastral.p(FALSE).

               RUN Busca_Dados ( INPUT "COMPLETO" ).
               
               IF  RETURN-VALUE <> "OK" THEN
                   RETURN.
               
               RUN p_abertura_nova.    
               
               IF  aux_msgalert <> "" THEN
                   DO:
                       MESSAGE UPPER(aux_msgalert).
                       PAUSE 2 NO-MESSAGE.
                   END.

               /* IF  aux_msgalert = "" THEN
                   RUN p_termo. 
               ELSE
                   DO:
                       MESSAGE UPPER(aux_msgalert).
                       PAUSE 2 NO-MESSAGE.
                   END. */

               IF  aux_inpessoa = 2  THEN
                   RUN p_financas(TRUE).  /* Imprime os dados preenchidos */ 

           END.    
      ELSE
      IF   FRAME-VALUE = tel_cadastro   THEN
           DO:
              aux_impcadto = TRUE.
              RUN fontes/ver_ficha_cadastral.p(FALSE).

           END.
      ELSE
      IF   FRAME-VALUE = tel_abertura   THEN
           DO:
            
              RUN Busca_Dados ( INPUT "ABERTURA" ). 

              IF  RETURN-VALUE <> "OK" THEN
                  RETURN.
              
              RUN p_abertura_nova.
           END.           
      /*
      IF   FRAME-VALUE = tel_integrac   THEN
           DO:
              RUN Busca_Dados ( INPUT "TERMO" ).
    
              IF  RETURN-VALUE <> "OK" THEN
                  RETURN.

              IF  aux_msgalert = "" THEN
                  DO: 
                      RUN p_termo.
                  END.
              ELSE
                  DO:
                      MESSAGE UPPER(aux_msgalert).
                      PAUSE 2 NO-MESSAGE.
                  END.   
           END.*/
      /**/
      ELSE
      IF FRAME-VALUE = tel_ctaassin   THEN
            DO:
                IF aux_inpessoa = 1 THEN
                    aux_idseqttl = tel_idseqttl.
                ELSE
                    aux_idseqttl = 0.
                
                EMPTY TEMP-TABLE cratavt.
        
                ASSIGN 	aux_qtregist = 0
                        aux_qtdprocu = 0.
        
                IF NOT VALID-HANDLE(h-b1wgen0063) THEN
                    RUN sistema/generico/procedures/b1wgen0063.p 
                    PERSISTENT SET h-b1wgen0063.
                    
                    RUN busca-titulares-impressao IN h-b1wgen0063(
                                      INPUT glb_cdcooper,
                                      INPUT tel_nrdconta,
                                     OUTPUT aux_qtregist,
                                     OUTPUT TABLE cratttl).

                    

                    IF VALID-HANDLE(h-b1wgen0063) THEN
                        DELETE OBJECT h-b1wgen0063.
                      
                    IF NOT VALID-HANDLE(h-b1wgen0058) THEN
                        RUN sistema/generico/procedures/b1wgen0058.p 
                        PERSISTENT SET h-b1wgen0058.
                      
                    RUN Busca_Dados IN h-b1wgen0058
                            (INPUT glb_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT glb_cdoperad,
                             INPUT glb_nmdatela,
                             INPUT 1,
                             INPUT tel_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT "C",
                             INPUT 0,
                             INPUT "",
                             INPUT ?,
                            OUTPUT TABLE cratavt,
                            OUTPUT TABLE tt-bens,
							OUTPUT aux_qtminast,
                            OUTPUT TABLE tt-erro) NO-ERROR.
        
                    FOR EACH cratavt NO-LOCK:
                          aux_qtdprocu = aux_qtdprocu + 1.
                    END.
                    
                    /*Resp Legal*/  
                    RUN busca_responsavel_legal IN h-b1wgen0058
                            (INPUT glb_cdcooper,          /*cdcooper*/
                             INPUT tel_nrdconta,          /*nrdconta*/
                             INPUT glb_cdagenci,          /*cdagenci*/
                             INPUT 0,                     /*nrdcaixa*/
                             INPUT glb_cdoperad,          /*cdoperad*/
                             INPUT glb_nmdatela,          /*nmdatela*/
                             INPUT 1,                     /*idorigem*/
                             INPUT glb_dtmvtolt,          /*dtmvtolt*/
                             OUTPUT aux_qtdrespo) NO-ERROR.
                    /*Resp Legal*/  
                    
                    IF VALID-HANDLE(h-b1wgen0058) THEN
                        DELETE OBJECT h-b1wgen0058.
                      
                    IF aux_qtdprocu > 0 OR aux_qtregist > 1 OR aux_qtdrespo > 0 THEN
                        DO:
                            
                            IF aux_inpessoa = 1 THEN DO: /*  Pessoa Fisica  */
                                CLEAR FRAME f_imprime_pf.
                                HIDE FRAME f_imprime_pf.
                            END.
                            ELSE
                                DO: /*  Pessoa Juridica  */
                                    CLEAR FRAME f_imprime_pj.
                                    HIDE FRAME f_imprime_pj.
                                END.
                             
                            Impressao: 	DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    
                                            IF aux_inpessoa = 1 THEN
                                                DO:
                                                    DISPLAY tel_imprtitu tel_imprproc tel_imprtodo WITH FRAME f_impressaopf.
                                                    CHOOSE FIELD tel_imprtitu tel_imprproc tel_imprtodo WITH FRAME f_impressaopf.
                                                END.
                                            ELSE
                                                DO:
                                                    DISPLAY tel_imprproc tel_imprtodo WITH FRAME f_impressaopj.
                                                    CHOOSE FIELD tel_imprproc tel_imprtodo WITH FRAME f_impressaopj.
                                                END.
                                                
                                            IF FRAME-VALUE = tel_imprtitu THEN
                                                DO:
                                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                        OPEN QUERY q_titulares FOR EACH cratttl NO-LOCK.
                                                        UPDATE b_titulares WITH FRAME f_titulares.
                                                        LEAVE.
                                                    END.
                    
                                                    IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                                                        DO:
                                                            HIDE FRAME f_titulares.
                                                            NEXT.
                                                        END.
                                                    LEAVE.
                                                END.
                                            ELSE
                                                IF FRAME-VALUE = tel_imprproc THEN
                                                    DO: 
                                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                            OPEN QUERY q_procuradores FOR EACH cratavt NO-LOCK.
                                                            UPDATE b_procuradores WITH FRAME f_procurador.
                                                            LEAVE.
                                                        END.
                    
                                                        IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                                                            DO:
                                                                HIDE FRAME f_procurador.
                                                                NEXT.
                                                            END.
                                                        LEAVE.
                                                    END.
                                            ELSE
                                                IF FRAME-VALUE = tel_imprtodo THEN
                                                    DO:
                                                    
                                                        FORM "Aguarde... Imprimindo Cartao Assinatura."
                                                        WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguardet.
                                                        
                                                        VIEW FRAME f_aguardet.
                                                        PAUSE 2 NO-MESSAGE.
                                                        HIDE FRAME f_aguardet NO-PAUSE.
                                                        
                                                        IF  NOT VALID-HANDLE(h-b1wgen0063) THEN
                                                            RUN sistema/generico/procedures/b1wgen0063.p 
                                                                PERSISTENT SET h-b1wgen0063.

                                                        RUN Imprime_Assinatura IN h-b1wgen0063(
                                                                INPUT glb_cdcooper,          /*cdcooper*/
                                                                INPUT glb_cdagenci,          /*cdagenci*/
                                                                INPUT 0,                     /*nrdcaixa*/
                                                                INPUT glb_cdoperad,          /*cdoperad*/
                                                                INPUT glb_nmdatela,          /*nmdatela*/
                                                                INPUT 1,                     /*idorigem*/
                                                                INPUT glb_cddopcao,          /*cddopcao*/
                                                                INPUT glb_dtmvtolt,          /*dtmvtolt*/
                                                                INPUT tel_nrdconta,          /*nrdconta*/
                                                                INPUT 0,                     /*nrdctato*/
                                                                INPUT 0,                     /*idseqttl*/
                                                                INPUT 3,                     /*tppessoa*/
                                                                INPUT 0,                     /*nrcpfcgc*/
                                                                INPUT par_nmendter,          /*nmendter*/
                                                                OUTPUT par_nmarqimp,         /*nmarqimp*/
                                                                OUTPUT TABLE tt-erro).
                                                            
                                                        IF VALID-HANDLE(h-b1wgen0063) THEN
                                                            DELETE PROCEDURE h-b1wgen0063.

                                                        IF RETURN-VALUE <> "OK" THEN
                                                            DO:
                                                                FIND FIRST tt-erro NO-ERROR.
                                                    
                                                                IF  AVAILABLE tt-erro THEN
                                                                    DO:
                                                                        MESSAGE tt-erro.dscritic.
                                                                        PAUSE(3) NO-MESSAGE.
                                                                        RETURN.
                                                                    END.
                                                            END.
                                                        
                                                        ASSIGN aux_nmarqimp = par_nmarqimp.

                                                        LEAVE.

                                                    END.
                                            
                                        END.
                        END.
                    ELSE
                        DO:
                            
                            FORM "Aguarde... Imprimindo Cartao Assinatura."
                            WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguardes.
                            
                            VIEW FRAME f_aguardes.
                            PAUSE 2 NO-MESSAGE.
                            HIDE FRAME f_aguardes NO-PAUSE.
                            
                            IF  NOT VALID-HANDLE(h-b1wgen0063) THEN
                                RUN sistema/generico/procedures/b1wgen0063.p 
                                    PERSISTENT SET h-b1wgen0063.

                            RUN Imprime_Assinatura IN h-b1wgen0063(
                                                   INPUT glb_cdcooper,     /*cdcooper*/
                                                   INPUT glb_cdagenci,     /*cdagenci*/
                                                   INPUT 0,                /*nrdcaixa*/
                                                   INPUT glb_cdoperad,     /*cdoperad*/
                                                   INPUT glb_nmdatela,     /*nmdatela*/
                                                   INPUT 1,                /*idorigem*/
                                                   INPUT glb_cddopcao,     /*cddopcao*/
                                                   INPUT glb_dtmvtolt,     /*dtmvtolt*/
                                                   INPUT tel_nrdconta,     /*nrdconta*/
                                                   INPUT 0,                /*nrdctato*/
                                                   INPUT 1,                /*idseqttl*/
                                                   INPUT 1,                /*tppessoa*/
                                                   INPUT 0,                /*nrcpfcgc*/
                                                   INPUT par_nmendter,     /*nmendter*/
                                                  OUTPUT par_nmarqimp,     /*nmarqimp*/
                                                  OUTPUT TABLE tt-erro).
                           
                            IF VALID-HANDLE(h-b1wgen0063) THEN
                                DELETE PROCEDURE h-b1wgen0063.

                            IF RETURN-VALUE <> "OK" THEN
                                DO:
                                    FIND FIRST tt-erro NO-ERROR.
                        
                                    IF AVAILABLE tt-erro THEN
                                        DO:
                                            MESSAGE tt-erro.dscritic.
                                            PAUSE(3) NO-MESSAGE.
                                            RETURN "NOK".
                                        END.
                                END.
                            
                            ASSIGN aux_nmarqimp = par_nmarqimp.
                            
                        END.
                        
                        IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                            DO:
                                NEXT.
                            END.
                        
            END.
       
      /**/

      ELSE
      IF   FRAME-VALUE = tel_fin_solt   THEN
           DO:
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                 ASSIGN glb_cdcritic = 0.
                 MESSAGE COLOR NORMAL 
                   "Imprimir o informativo financeiro em (B)ranco ou "
                   "(P)reenchido?"
                   UPDATE tel_tpimpres. 
                 LEAVE.
    
              END.  /*  Fim do DO WHILE TRUE  */

              RUN Busca_Dados ( INPUT "FINANCEIRO" ).

              IF  RETURN-VALUE <> "OK" THEN
                  RETURN.

              RUN p_financas(FALSE).   /*  Pergunta se os dados preenchidos 
                                             SOMENTE PARA PESSOA JURIDICA    */
           END.
       
      OUTPUT STREAM str_1 CLOSE.

      /*** nao necessario ao programa somente para nao dar erro 
           de compilacao na rotina de impressao ****/
      FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                               NO-LOCK NO-ERROR.

      par_flgrodar = TRUE.
      

      IF   SEARCH(aux_nmarqimp) = ? THEN
           RETURN.
        
     
      { includes/impressao.i }
                            
      LEAVE.
   
   END.
   
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE MESSAGE NO-PAUSE.

/* .......................................................................... */

PROCEDURE p_financas:

  DEF INPUT PARAM par_tipconsu AS LOGICAL                             NO-UNDO.

  FORM "Aguarde... Imprimindo ficha de informativo financeiro"
       WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

  FORM SKIP(1)
       tt-finan-cabec.nmextcop            AT 1 FORMAT "x(50)" NO-LABEL SKIP
       tt-finan-cabec.dsendcop            AT 1 FORMAT "x(50)" NO-LABEL SKIP
       tt-finan-cabec.nrdocnpj            AT 1 FORMAT "x(25)" NO-LABEL SKIP(1)
       "INFORMATIVO DE DADOS FINANCEIROS" AT 26 SKIP(1)
       WITH COLUMN 01 SIDE-LABELS NO-BOX FRAME f_cabecalho.

  FORM 
     "-------------------------------------------------------------------------~-------"   
       SKIP
       WITH COLUMN 01 NO-LABELS NO-BOX FRAME f_traco.

  FORM "EMPRESA:"                              AT 01
       tt-finan-ficha.nmprimtl FORMAT "x(60)"  AT 11 SKIP
       WITH COLUMN 01 WIDTH 80 NO-LABELS NO-BOX FRAME f_fichafin_1.

  FORM "C.N.P.J.:"                             AT 01
       tt-finan-ficha.nrcpfcgc FORMAT "x(18)"  AT 11
       "Data Base:"                            AT 52
       tt-finan-ficha.dsdtbase FORMAT "x(07)"  AT 65 SKIP
       WITH COLUMN 01 WIDTH 80 NO-LABELS NO-BOX FRAME f_fichafin_2.

  FORM "Contas Ativas (Valores em R$)"            AT 01
       "Contas Passivas (Valores em R$)"          AT 46 SKIP(1)
       "Caixa,Bancos,Aplicacoes:"                 AT 01
       tt-finan-ficha.vlcxbcaf     FORMAT "x(15)" AT 25
       "Fornecedores:"                            AT 53
       tt-finan-ficha.vlfornec     FORMAT "x(15)" AT 66 SKIP(1)
       "Contas a Receber:"                        AT 08   
       tt-finan-ficha.vlctarcb     FORMAT "x(15)" AT 25
       "Outros Passivos:"                         AT 50
       tt-finan-ficha.vloutpas     FORMAT "x(15)" AT 66 SKIP(1)
       "Estoques:"                                AT 16 
       tt-finan-ficha.vlrestoq     FORMAT "x(15)" AT 25 SKIP(1)
       "Outros Ativos:"                           AT 11
       tt-finan-ficha.vloutatv     FORMAT "x(15)" AT 25 SKIP(1)
       "Imobilizado:"                             AT 13
       tt-finan-ficha.vlrimobi     FORMAT "x(15)" AT 25
       "Endividamento Bancario:"                  AT 43   
       tt-finan-ficha.vldivbco     FORMAT "x(15)" AT 66 SKIP(1)
       "Ultima Alteracao:"                        AT 01
       tt-finan-ficha.dtultatu[01] FORMAT "99/99/9999" 
       "realizado pelo operador:"
       tt-finan-ficha.opultatu[01] FORMAT "X(25)" SKIP
       WITH COLUMN 01 WIDTH 80 NO-LABELS NO-BOX FRAME f_fichafin_3.

  FORM "Emprestimos Bancarios"                                  AT 01
       "(Saldos de operacao de descontos de cheque/duplicatas)" AT 23   
       SKIP(1)
       "Nome do Banco"                                          AT 01
       "Tipo de Operacao"                                       AT 16
       "Valor (R$)"                                             AT 39
       "Garantia"                                               AT 50
       "Vencimento"                                             AT 69 
       SKIP(1)
       tt-finan-ficha.cdbccxlt[01]  FORMAT "x(14)"           AT 01
       tt-finan-ficha.dstipope[01]  FORMAT "x(18)"           AT 16
       tt-finan-ficha.vlropera[01]  FORMAT "x(14)"           AT 35
       tt-finan-ficha.garantia[01]  FORMAT "x(18)"           AT 50
       tt-finan-ficha.dsvencto[01]  FORMAT "x(12)"           AT 69 SKIP(1)
       tt-finan-ficha.cdbccxlt[02]  FORMAT "x(14)"           AT 01
       tt-finan-ficha.dstipope[02]  FORMAT "x(18)"           AT 16
       tt-finan-ficha.vlropera[02]  FORMAT "x(14)"           AT 35
       tt-finan-ficha.garantia[02]  FORMAT "x(18)"           AT 50
       tt-finan-ficha.dsvencto[02]  FORMAT "x(12)"           AT 69 SKIP(1)
       tt-finan-ficha.cdbccxlt[03]  FORMAT "x(14)"           AT 01
       tt-finan-ficha.dstipope[03]  FORMAT "x(18)"           AT 16
       tt-finan-ficha.vlropera[03]  FORMAT "x(14)"           AT 35
       tt-finan-ficha.garantia[03]  FORMAT "x(18)"           AT 50
       tt-finan-ficha.dsvencto[03]  FORMAT "x(12)"           AT 69 SKIP(1)
       tt-finan-ficha.cdbccxlt[04]  FORMAT "x(14)"           AT 01
       tt-finan-ficha.dstipope[04]  FORMAT "x(18)"           AT 16
       tt-finan-ficha.vlropera[04]  FORMAT "x(14)"           AT 35
       tt-finan-ficha.garantia[04]  FORMAT "x(18)"           AT 50
       tt-finan-ficha.dsvencto[04]  FORMAT "x(12)"           AT 69 SKIP(1)
       tt-finan-ficha.cdbccxlt[05]  FORMAT "x(14)"           AT 01
       tt-finan-ficha.dstipope[05]  FORMAT "x(18)"           AT 16
       tt-finan-ficha.vlropera[05]  FORMAT "x(14)"           AT 35
       tt-finan-ficha.garantia[05]  FORMAT "x(18)"           AT 50
       tt-finan-ficha.dsvencto[05]  FORMAT "x(12)"           AT 69 SKIP(1)
       "Ultima Alteracao:"                                   AT 01
       tt-finan-ficha.dtultatu[02]  FORMAT "99/99/9999" 
       "realizado pelo operador:"
       tt-finan-ficha.opultatu[02]  FORMAT "X(25)" SKIP
       WITH COLUMN 01 WIDTH 80 NO-LABELS NO-BOX FRAME f_fichafin_4.
     
  FORM "Contas de Resultados (ultimos 12 meses/valores em R$)"  AT 01
       "Prazos Medios (em dias)"                                AT 58 SKIP(1)
       "Receita Bruta de Vendas:"                               AT 10
       tt-finan-ficha.vlrctbru            FORMAT "x(19)"        AT 35
       "Recebimentos:"                                          AT 58
       tt-finan-ficha.ddprzrec            FORMAT "x(10)"        AT 71 SKIP(1)
       "Custo e Despesas Administrativas:"                      AT 01
       tt-finan-ficha.vlctdpad            FORMAT "x(19)"        AT 35
       "Pagamentos:"                                            AT 60
       tt-finan-ficha.ddprzpag            FORMAT "x(10)"        AT 71 SKIP(1)
       "Despesas Financeiras:"                                  AT 13
       tt-finan-ficha.vldspfin            FORMAT "x(19)"        AT 35 SKIP(1)
       "Ultima Alteracao:"                                      AT 01
       tt-finan-ficha.dtultatu[03]        FORMAT "99/99/9999" 
       "realizado pelo operador:"
       tt-finan-ficha.opultatu[03]        FORMAT "X(25)" SKIP
       WITH COLUMN 01 WIDTH 80 NO-LABELS NO-BOX FRAME f_fichafin_5.

     
  FORM "Relacao do Faturamento Mensal Bruto dos ultimos 12 meses" AT 01
       "(valores em R$)"                                          AT 58   
       SKIP(1)
       "Mes/Ano    Faturamento"                                   AT 05
       "Mes/Ano    Faturamento"                                   AT 32
       "Mes/Ano    Faturamento"                                   AT 59 SKIP(1)
       "1. "                                                      AT 01
       tt-finan-ficha.mesanoft[01]       FORMAT "x(08)"           AT 04
       tt-finan-ficha.vlrftbru[01]       FORMAT "x(14)"           AT 13
       "2. "                                                      AT 28
       tt-finan-ficha.mesanoft[02]       FORMAT "x(08)"           AT 31
       tt-finan-ficha.vlrftbru[02]       FORMAT "x(14)"           AT 40
       "3. "                                                      AT 55
       tt-finan-ficha.mesanoft[03]       FORMAT "x(08)"           AT 58
       tt-finan-ficha.vlrftbru[03]       FORMAT "x(14)"           AT 67 SKIP(1)
       "4. "                                                      AT 01
       tt-finan-ficha.mesanoft[04]       FORMAT "x(08)"           AT 04
       tt-finan-ficha.vlrftbru[04]       FORMAT "x(14)"           AT 13
       "5. "                                                      AT 28
       tt-finan-ficha.mesanoft[05]       FORMAT "x(08)"           AT 31
       tt-finan-ficha.vlrftbru[05]       FORMAT "x(14)"           AT 40
       "6. "                                                      AT 55
       tt-finan-ficha.mesanoft[06]       FORMAT "x(08)"           AT 58
       tt-finan-ficha.vlrftbru[06]       FORMAT "x(14)"           AT 67 SKIP(1)
       "7. "                                                      AT 01
       tt-finan-ficha.mesanoft[07]       FORMAT "x(08)"           AT 04
       tt-finan-ficha.vlrftbru[07]       FORMAT "x(14)"           AT 13
       "8. "                                                      AT 28
       tt-finan-ficha.mesanoft[08]       FORMAT "x(08)"           AT 31
       tt-finan-ficha.vlrftbru[08]       FORMAT "x(14)"           AT 40
       "9. "                                                      AT 55
       tt-finan-ficha.mesanoft[09]       FORMAT "x(08)"           AT 58
       tt-finan-ficha.vlrftbru[09]       FORMAT "x(14)"           AT 67 SKIP(1)
       "10."                                                      AT 01
       tt-finan-ficha.mesanoft[10]       FORMAT "x(08)"           AT 04
       tt-finan-ficha.vlrftbru[10]       FORMAT "x(14)"           AT 13
       "11."                                                      AT 28
       tt-finan-ficha.mesanoft[11]       FORMAT "x(08)"           AT 31
       tt-finan-ficha.vlrftbru[11]       FORMAT "x(14)"           AT 40
       "12."                                                      AT 55
       tt-finan-ficha.mesanoft[12]       FORMAT "x(08)"           AT 58
       tt-finan-ficha.vlrftbru[12]       FORMAT "x(14)"           AT 67 SKIP(1)
       "Ultima Alteracao:"                                        AT 01
       tt-finan-ficha.dtultatu[04]       FORMAT "99/99/9999" 
       "realizado pelo operador:"
       tt-finan-ficha.opultatu[04]       FORMAT "X(25)" SKIP
       WITH COLUMN 01 WIDTH 80 NO-LABELS NO-BOX FRAME f_fichafin_6.
     
  FORM "Informacoes Adicionais:"         SKIP
       tt-finan-ficha.dsinfadi[01]       FORMAT "x(74)"           AT 01 SKIP
       tt-finan-ficha.dsinfadi[02]       FORMAT "x(74)"           AT 01 SKIP
       tt-finan-ficha.dsinfadi[03]       FORMAT "x(74)"           AT 01 SKIP
       tt-finan-ficha.dsinfadi[04]       FORMAT "x(74)"           AT 01 SKIP
       tt-finan-ficha.dsinfadi[05]       FORMAT "x(74)"           AT 01 SKIP(1)
       "Ultima Alteracao:"                                        AT 01
       tt-finan-ficha.dtultatu[05]       FORMAT "99/99/9999" 
       "realizado pelo operador:"
       tt-finan-ficha.opultatu[05]       FORMAT "X(25)" SKIP      
       WITH COLUMN 01 WIDTH 80 NO-LABELS NO-BOX FRAME f_fichafin_7.

  FORM "Representante(s) Legal(is):"                            AT 01   
       SKIP(1)
       "Nome:_____________________________________________"     AT 01   
       "CPF:_______________________"                            AT 54   
       SKIP(2)
       "Nome:_____________________________________________"     AT 01 
       "CPF:_______________________"                            AT 54    
       WITH COLUMN 01 WIDTH 80 SIDE-LABELS NO-BOX FRAME f_fichafin_8.     

       
  HIDE MESSAGE NO-PAUSE.

  VIEW FRAME f_aguarde.
  PAUSE 2 NO-MESSAGE.
  HIDE FRAME f_aguarde NO-PAUSE.

  FIND FIRST tt-tprelato WHERE tt-tprelato.nmrelato = "FINANCEIRO" NO-ERROR.

  IF  AVAILABLE tt-tprelato THEN
      DO:
         IF  tt-tprelato.msgrelat <> "" THEN
             MESSAGE tt-tprelato.msgrelat.

         IF  tt-tprelato.flgbloqu THEN
             RETURN.
      END.

  OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84 APPEND.

  PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

  PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
      
  FIND FIRST tt-finan-cabec NO-ERROR.

  FIND FIRST tt-finan-ficha NO-ERROR.

  DISPLAY STREAM str_1 
      tt-finan-cabec.nmextcop    
      tt-finan-cabec.dsendcop    
      tt-finan-cabec.nrdocnpj 
      WITH FRAME f_cabecalho.
                     
  VIEW STREAM str_1 FRAME f_traco.

  DISPLAY STREAM str_1 
      tt-finan-ficha.nmprimtl 
      WITH FRAME f_fichafin_1.

  VIEW STREAM str_1 FRAME f_traco.

  DISPLAY STREAM str_1 
      tt-finan-ficha.nrcpfcgc  
      tt-finan-ficha.dsdtbase
      WITH FRAME f_fichafin_2.

  VIEW STREAM str_1 FRAME f_traco.

  DISPLAY STREAM str_1 
      tt-finan-ficha.vlcxbcaf  
      tt-finan-ficha.vlfornec  
      tt-finan-ficha.vlctarcb  
      tt-finan-ficha.vloutpas
      tt-finan-ficha.vlrestoq  
      tt-finan-ficha.vloutatv  
      tt-finan-ficha.vlrimobi  
      tt-finan-ficha.vldivbco
      tt-finan-ficha.dtultatu[01]
      tt-finan-ficha.opultatu[01]
      WITH FRAME f_fichafin_3.

  VIEW STREAM str_1 FRAME f_traco.

  DISPLAY STREAM str_1 
      tt-finan-ficha.cdbccxlt[01]  
      tt-finan-ficha.dstipope[01]  
      tt-finan-ficha.vlropera[01]
      tt-finan-ficha.garantia[01]  
      tt-finan-ficha.dsvencto[01]  
      tt-finan-ficha.cdbccxlt[02]
      tt-finan-ficha.dstipope[02]  
      tt-finan-ficha.vlropera[02]  
      tt-finan-ficha.garantia[02]
      tt-finan-ficha.dsvencto[02]  
      tt-finan-ficha.cdbccxlt[03]  
      tt-finan-ficha.dstipope[03]
      tt-finan-ficha.vlropera[03]  
      tt-finan-ficha.garantia[03]  
      tt-finan-ficha.dsvencto[03]
      tt-finan-ficha.cdbccxlt[04]  
      tt-finan-ficha.dstipope[04]  
      tt-finan-ficha.vlropera[04]
      tt-finan-ficha.garantia[04]  
      tt-finan-ficha.dsvencto[04]  
      tt-finan-ficha.cdbccxlt[05]
      tt-finan-ficha.dstipope[05]  
      tt-finan-ficha.vlropera[05]  
      tt-finan-ficha.garantia[05]
      tt-finan-ficha.dsvencto[05]  
      tt-finan-ficha.dtultatu[02] 
      tt-finan-ficha.opultatu[02] 
      WITH FRAME f_fichafin_4.
      
  VIEW STREAM str_1 FRAME f_traco.

  DISPLAY STREAM str_1 
      tt-finan-ficha.vlrctbru  
      tt-finan-ficha.ddprzrec  
      tt-finan-ficha.vlctdpad  
      tt-finan-ficha.ddprzpag
      tt-finan-ficha.vldspfin  
      tt-finan-ficha.dtultatu[03] 
      tt-finan-ficha.opultatu[03] 
      WITH FRAME f_fichafin_5.

  VIEW STREAM str_1 FRAME f_traco.

  DISPLAY STREAM str_1 
      tt-finan-ficha.mesanoft[01]  
      tt-finan-ficha.vlrftbru[01]   
      tt-finan-ficha.mesanoft[02]
      tt-finan-ficha.vlrftbru[02]  
      tt-finan-ficha.mesanoft[03]   
      tt-finan-ficha.vlrftbru[03]
      tt-finan-ficha.mesanoft[04]  
      tt-finan-ficha.vlrftbru[04]   
      tt-finan-ficha.mesanoft[05]
      tt-finan-ficha.vlrftbru[05]  
      tt-finan-ficha.mesanoft[06]   
      tt-finan-ficha.vlrftbru[06]
      tt-finan-ficha.mesanoft[07]  
      tt-finan-ficha.vlrftbru[07]   
      tt-finan-ficha.mesanoft[08]
      tt-finan-ficha.vlrftbru[08]  
      tt-finan-ficha.mesanoft[09]   
      tt-finan-ficha.vlrftbru[09]
      tt-finan-ficha.mesanoft[10]  
      tt-finan-ficha.vlrftbru[10]   
      tt-finan-ficha.mesanoft[11]
      tt-finan-ficha.vlrftbru[11]  
      tt-finan-ficha.mesanoft[12]   
      tt-finan-ficha.vlrftbru[12]
      tt-finan-ficha.dtultatu[04] 
      tt-finan-ficha.opultatu[04] 
      WITH FRAME f_fichafin_6.

  VIEW STREAM str_1 FRAME f_traco.

  DISPLAY STREAM str_1 
      tt-finan-ficha.dsinfadi[01]  
      tt-finan-ficha.dsinfadi[02]   
      tt-finan-ficha.dsinfadi[03]
      tt-finan-ficha.dsinfadi[04]  
      tt-finan-ficha.dsinfadi[05]   
      tt-finan-ficha.dtultatu[05] 
      tt-finan-ficha.opultatu[05] 
      WITH FRAME f_fichafin_7.

  VIEW STREAM str_1 FRAME f_traco.

  VIEW STREAM str_1 FRAME f_fichafin_8.

  OUTPUT STREAM str_1 CLOSE.
  
END.  /*  Procedure  p_fichafinanceiro  */

PROCEDURE p_termo:

  FORM "Aguarde... Imprimindo Termo de Adesao."
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.
                                                              
  FORM "\0332\022\024\033\120"
       tt-termo-ident.nmextcop AT 06  NO-LABEL           FORMAT "x(50)"
       SKIP(2)
       tt-termo-ident.cdagenci AT 48  LABEL "PA"         FORMAT "zz9"
       tt-termo-ident.nrdconta AT 61  LABEL "CONTA/DV"   FORMAT "X(10)"
       SKIP(1)
       WITH NO-BOX NO-LABELS SIDE-LABELS DOWN WIDTH 80 FRAME f_identi.
  
  FORM SKIP(3)
    "\033\105"
    "TERMO DE CONHECIMENTO E AUTORIZACAO"           AT 22
    "\033\106"
    SKIP(3)
    "Em  conformidade  com  a  legislacao  vigente  e  os  normativos  do"
    " Banco" SKIP
    "Central  do  Brasil,  como  titular  da  conta-corrente  "
    "\033\105" tt-termo-ident.nrdconta "\033\106"   ", na" 
    SKIP
    "\033\105"
    tt-termo-ident.nmextcop      FORMAT "x(50)" 
    "-" 
    tt-termo-ident.nmrescop      FORMAT "x(13)"
    "\033\106"
    ",  de-"  
    SKIP
    "claro que:"  
    SKIP
    "a) Tenho conhecimento que a Cooperativa  tem  parceria com outras"
    "institui-" 
    SKIP
    "coes para execucao dos servicos de: Centralizacao da Compensacao de"
    "Cheques"
    SKIP
    "e Outros Papeis (COMPE); manutencao do Cadastro de Emitentes de Cheques"
    "sem"
    SKIP
    "Fundos; Sistema de Liquidacao de Pagamentos e Transferencias"
    "Interbancarias"
    SKIP
    "do Sistema Financeiro Nacional; e, a disponibilizacao  de  Cartoes e Conve-"
    SKIP
    "nios diversos;"
    SKIP
    "b) Minha relacao contratual e exclusiva com a Cooperativa, sendo que"
    "somen-"
    SKIP      
    "te poderei cobrar desta as responsabilidades decorrentes  da  prestacao de" 
    SKIP
    "servicos por terceiros, podendo a Cooperativa  se  valer do direito de"     
    "re-" 
    SKIP
    "gresso; e"
    SKIP
    "c) Autorizo a Cooperativa a repassar minhas informacoes cadastrais as"
    "ins-" 
    SKIP
    "tituicoes parceiras para consecucao dos servicos relacionados no item"
    "'a'." 
    SKIP(3)
    tt-termo-ident.dsmvtolt FORMAT "x(80)"
    SKIP(6)
    WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 80 
        FRAME f_termo_adesao.
 
  FORM "________________________________________" SKIP
       tt-termo-assin.nmprimtl                    FORMAT "x(40)"    SKIP
       "CPF/CNPJ:"  tt-termo-assin.nrcpfcgc       FORMAT "x(20)"    SKIP(9)
       "________________________________________" SKIP
       "OPERADOR -" tt-termo-assin.nmoperad       FORMAT "x(40)" 
       SKIP(1)
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 80 
                   FRAME f_inte_ass1.

  FORM "______________________________________________" SKIP
       tt-termo-asstl.nmprimtl                          FORMAT "x(40)"  SKIP
       "CPF/CNPJ:"  tt-termo-asstl.nrcpfcgc             SKIP(3)
       "______________________________________________" SKIP
       tt-termo-asstl.nmextttl                          FORMAT "x(40)" SKIP
       "CPF/CNPJ:"  tt-termo-asstl.nrcpfttl             FORMAT "x(20)" SKIP(5)
       "________________________________________"       SKIP
       "OPERADOR -" tt-termo-asstl.nmoperad             FORMAT "x(40)" SKIP(1)
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 80 
                   FRAME f_inte_ass2.

  HIDE MESSAGE NO-PAUSE.

  FIND FIRST tt-termo-ident NO-ERROR.

  FIND FIRST tt-termo-assin NO-ERROR.

  VIEW FRAME f_aguarde.
  PAUSE 2 NO-MESSAGE.
  HIDE FRAME f_aguarde NO-PAUSE.
           
  FIND FIRST tt-tprelato WHERE tt-tprelato.nmrelato = "TERMO" NO-ERROR.

  IF  AVAILABLE tt-tprelato THEN
      DO:
         IF  tt-tprelato.msgrelat <> "" THEN
             MESSAGE tt-tprelato.msgrelat.

         IF  tt-tprelato.flgbloqu THEN
             RETURN.
      END.

  OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84
         APPEND.

  PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
           
  PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

  DISPLAY STREAM str_1  
      tt-termo-ident.nmextcop  
      tt-termo-ident.nrdconta 
      tt-termo-ident.cdagenci  
      WITH FRAME f_identi.

  DOWN STREAM str_1 WITH FRAME f_identi.

  DISPLAY STREAM str_1  
      tt-termo-ident.nrdconta        
      tt-termo-ident.nmextcop 
      tt-termo-ident.nmrescop    
      tt-termo-ident.dsmvtolt
      WITH FRAME f_termo_adesao.

  FIND FIRST tt-termo-asstl NO-ERROR.

  IF  AVAILABLE tt-termo-asstl AND tt-termo-asstl.nrcpfttl <> "" THEN
      DISPLAY STREAM str_1 
          tt-termo-asstl.nmprimtl 
          tt-termo-asstl.nrcpfcgc
          tt-termo-asstl.nmextttl 
          tt-termo-asstl.nrcpfttl
          tt-termo-asstl.nmoperad 
          WITH FRAME f_inte_ass2.
  ELSE
      DISPLAY STREAM str_1 
          tt-termo-assin.nmprimtl 
          tt-termo-assin.nrcpfcgc
          tt-termo-assin.nmoperad
          WITH FRAME f_inte_ass1.
                                        
  DISPLAY STREAM str_1 WITH FRAME f_ass_reponsavel_pf.

  DISPLAY STREAM str_1 WITH FRAME f_declara_pf. 
                      
  OUTPUT STREAM str_1 CLOSE.
  
END.  /*  Procedure  p_termoitg  */ 


PROCEDURE p_abertura_nova:

  FORM SKIP(1)
       "\033\105"
       "PROPOSTA/CONTRATO DE ABERTURA DE CONTA CORRENTE"   AT 04              
       tt-abert-ident.dstitulo    FORMAT "x(15)"   AT 52
       "\033\106"
       SKIP(1)
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_cabec.

  FORM SKIP
       "\033\1051.IDENTIFICACAO:\033\106"
       SKIP
       "\033\1051.1.Cooperativa:\033\106"
       tt-abert-ident.nmextcop  FORMAT "x(50)"                 SKIP
       tt-abert-ident.dslinha1  FORMAT "x(58)"      AT 18      SKIP
       tt-abert-ident.dslinha2  FORMAT "x(58)"      AT 18      SKIP
       tt-abert-ident.dslinha3  FORMAT "x(58)"      AT 18      SKIP
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                            FRAME f_identificacao.

  /*  --------- PESSOA FISICA ---------  */

  FORM "\033\1051.2.Cooperado(a) Titular:\033\106"
       tt-abert-psfis.nmprimtl          FORMAT "x(40)"                 SKIP
       "Conta Corrente:"                            AT 19
       tt-abert-psfis.nrdconta          FORMAT "x(10)"
       ", CPF:"
       tt-abert-psfis.nrcpfcgc          FORMAT "x(14)"                 SKIP
       "RG:"                                        AT 19
       tt-abert-psfis.nrdocmto          FORMAT "x(30)"                 SKIP
       "\033\1051.3.Endereco:\033\106"
       tt-abert-psfis.dslinha1          FORMAT "x(61)"                 SKIP
       tt-abert-psfis.dslinha2          FORMAT "x(61)"      AT 15      SKIP
       "\033\1051.4.Estado Civil:\033\106"
       tt-abert-psfis.dsestcvl          FORMAT "x(30)"                 SKIP
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_identificacao_pf.

  FORM "\033\1051.5.Dados do Representante Legal:\033\106"
       tt-abert-psfis.nmrepleg              FORMAT "x(40)"  SKIP
       "CPF:"                                            AT 35
       tt-abert-psfis.nrcpfrep /*nrcpfcgc*/ FORMAT "x(14)"                     
       SKIP
       "RG:"                                             AT 35
       tt-abert-psfis.nrdocrep /*nrdocmto*/ FORMAT "x(20)"  SKIP
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_representacao_pf.
 
  /* FORM SKIP(1)
       "\033\1052.DADOS COMPLEMENTARES\033\106"
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_complem_pf_cabec. */
  
  FORM SKIP(1)
       "\033\1052.DADOS COMPLEMENTARES\033\106"
       "\033\105" 
       tt-abert-compf.dstitulo  FORMAT "x(33)" AT 01
       "\033\106"
       tt-abert-compf.nmprimtl  FORMAT "x(40)"       SKIP
       "CPF:"                                  AT 25
       tt-abert-compf.nrcpfcgc  FORMAT "x(14)"                 
       ", RG:"
       tt-abert-compf.nrdocmto  FORMAT "x(20)"            SKIP
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_complem_pf.
  
  FORM SKIP(1)
       "\033\1053.DECLARACOES \033\106"
       SKIP
       "O(a) \033\105Cooperado(a)\033\106, os  demais titulares e os seus  representantes legais,"
       SKIP 
       "se  este  for  o caso, propoem e a \033\105Cooperativa\033\106 aceita a abertura de conta"
       SKIP 
       "corrente, declarando em carater irrevogavel e irretratavel, para todos os"
       SKIP 
       "efeitos legais, que:"
       SKIP(1) 
       
       "a) Estao de   pleno acordo  com   as  disposicoes  contidas nas \033\105CLAUSULAS\033\106"       
       SKIP 
       "\033\105GERAIS    APLICAVEIS     AO     CONTRATO     DE     CONTA    CORRENTE   E\033\106"
       SKIP 
       "\033\105CONTA INVESTIMENTO\033\106, disponivel no site da \033\105Cooperativa\033\106 (www.viacredi.coop."
       SKIP
       "br) e registrado no Cartorio de Registro de Titulos e Documentos da cida-"
       SKIP
       "de   Blumenau, sob  n 99742, Livro B 340, Folha  005  em  13/11/2006, que"
       SKIP
       "integram  este  contrato, formando um documento unico e indivisivel, cuja"
       SKIP
       "copia recebe no ato da assinatura deste instrumento."       
       SKIP(1)
       
       "b) As  informacoes  e  elementos  comprobatorios fornecidos para abertura"
       SKIP
       "da  conta  corrente, constantes na ficha cadastral anexa, sao a expressao"
       SKIP
       "da   verdade.  Desde   ja  autoriza(m)  a \033\105Cooperativa\033\106  e outras institui-"
       SKIP
       "coes  financeiras    parceiras, a   efetuar  consultas  cadastrais  junto"       
       SKIP
       "ao CADIN, SPC, Serasa, Sistema de Informacoes de Credito do Banco Central"
       SKIP 
       "do  Brasil - SCR, e  demais  bancos de dados que se fizerem necessarios a"
       SKIP
       "prestacao  dos  servicos  financeiros demandados pelo(s) titular(es), nos"
       SKIP
       "termos do previsto  na  legislacao vigente, podendo enviar seus dados aos"
       SKIP
       "orgaos  publicos  ou  privados, administradores  de banco de dados, entre"
       SKIP 
       "outros."
       
       SKIP(1)
       "Declara(m) ainda estar(estarem) cientes de que:"
       SKIP(1)
       
       "c) A conta aberta sera movimentada de forma  isolada pelo(a) \033\105Cooperado(a)"
       SKIP 
       "Titular\033\106, ou, quando possuir  mais de um titular, sera movimentada separa-"
       SKIP 
       "damente por cada um deles, podendo estes disporem do saldo que nela exis-"
       SKIP 
       "tir, mediante emissao de cheques, recibos, TEDs, ordens de pagamentos, ou"
       SKIP 
       "quaisquer  outros  meios  devidamente regulamentados  pelo  Banco Central"
       SKIP 
       "do  Brasil,  sendo  que  o encerramento da conta somente podera ser feito"
       SKIP 
       "pelo(a) \033\105Cooperado(a) Titular\033\106."
       SKIP(1)
       
       "d) A \033\105Cooperativa\033\106 possui  parceria  com  outras instituicoes para execucao"
       SKIP 
       "dos servicos  de  Centralizacao  da  Compensacao  de Cheques e Outros Pa-"
       SKIP
       "peis (COMPE); Manutencao do Cadastro de Emitentes de Cheques  sem Fundos;"
       SKIP
       "Sistema  de  Liquidacao  de Pagamentos e Transferencias Interbancarias do"
       SKIP
       "Sistema  Financeiro  Nacional e, para disponibilizacao  de cartoes e con-"
       SKIP
       "venios diversos, autorizando para a consecucao destes servicos, o repasse"
       SKIP
       "das informacoes cadastrais as instituicoes parceiras."
       SKIP(1)    
       
       "e) Podera(ao) ter  acesso  aos canais de autoatendimento disponibilizados"
       SKIP
       "pela \033\105Cooperativa\033\106, ou ainda, outros que venham a ser disponibilizados, pa-"
       SKIP
       "ra realizacao  de movimentacoes, transacoes e contratacoes financeiras em"
       SKIP
       "sua conta corrente. Atualmente, sao disponibilizados os seguintes canais:"
       SKIP(1)       
       
       "f) Conta online: canal  eletronico via internet para acesso a informacoes"
       SKIP 
       "sobre  produtos  e servicos da \033\105Cooperativa\033\106, que  possibilita a realizacao"
       SKIP
       "de  consultas, movimentacoes, antecipacao  de pagamento de contratos (ob-"
       SKIP
       "servadas as regras estipuladas para este servico), transacoes e contrata-"
       SKIP 
       "coes, inclusive  de  credito, diretamente  em sua conta. Apos a liberacao"
       SKIP
       "da  conta  online  e  cadastramento  da  senha no Posto de Atendimento da"
       SKIP
       "\033\105Cooperativa\033\106, o  primeiro  acesso  devera  ser realizado pelo Cooperado(a)"
       SKIP
       "Titular  no  prazo de 03 (tres) dias, sob pena de cancelamento. E de res-"
       SKIP
       "ponsabilidade  do(s) titular(es) os atos praticados por meio deste canal,"
       SKIP
       "ficando a \033\105Cooperativa\033\106 isenta  de  qualquer  responsabilidade  por eventu-"
       SKIP
       "ais prejuizos  sofridos, inclusive  causados  a terceiros, decorrentes de"
       SKIP
       "atos praticados mediante a utilizacao de senha pessoal."
       SKIP(15)       
       
       "g) Aplicativo para celular: canal  para  acesso a  conta, mediante uso da"
       SKIP
       "mesma  senha  de  utilizacao da Conta Online, podendo realizar consultas,"
       SKIP
       "movimentacoes, transacoes e contratacoes relativas a produtos e servicos,"
       SKIP
       "inclusive  de credito, diretamente em sua conta, conforme disponibilizado"
       SKIP
       "pela \033\105Cooperativa\033\106."
       SKIP(1)
       
       "h) Terminal  de  autoatendimento: equipamento  localizado  nos  Postos de"
       SKIP
       "Atendimento ou em outros locais de acesso  publico, devidamente identifi-"
       SKIP
       "cados  com  as  credenciais da \033\105Cooperativa\033\106, para realizacao de consultas,"
       SKIP
       "movimentacoes, transacoes  e  contratacoes relativas a produtos e  servi-"
       SKIP
       "cos, inclusive de credito, diretamente na conta corrente."
       SKIP(1)
       
       "i) Sao disponibilizados os servicos de Tele Saldo e SAC (Servico de Aten-"
       SKIP
       "dimento ao Cooperado), por meio de atendimento telefonico,  para realizar"
       SKIP
       "consultas, obter informacoes, solicitar e autorizar transacoes, inclusive"
       SKIP
       "as  relativas  a  contratacao  de  produtos  e  servicos,  ofertadas pela"
       SKIP
       "\033\105Cooperativa\033\106, a qual reserva-se  no  direito de, e a  seu exclusivo crite-"
       SKIP
       "rio, disponibilizar novas  informacoes, operacoes e  servicos, ou excluir"
       SKIP
       "quaisquer daqueles ofertados na data da formalizacao da abertura da conta"
       SKIP
       "corrente. Por medida de seguranca fica a \033\105Cooperativa\033\106 autorizada  a reali-"
       SKIP
       "zar gravacoes das solicitacoes e instrucoes telefonicas."
       SKIP(1)
       
       "j) A \033\105Cooperativa\033\106 podera disponibilizar por meio dos canais de autoatendi-"
       SKIP
       "mento  existentes,  ou  ainda  aqueles  que  venham a ser criados, a pos-"
       SKIP
       "sibilidade de  contratacao de  operacao de  credito, desde que  os requi-"
       SKIP
       "sitos  necessarios  para  sua  contratacao  e  as regras estipuladas pela"
       SKIP
       "\033\105Cooperativa\033\106 sejam observados. Tratando-se de conta que possuir mais de um"
       SKIP
       "titular, o(a) \033\105Cooperado(a) Titular\033\106 declara-se ciente que os  demais titu-"
       SKIP
       "lares da conta tambem poderao realizar, em seu nome, as contratacoes pre-"
       SKIP
       "vistas no item acima, sendo de sua inteira reponsabilidade o adimplemento"
       SKIP
       "das obrigacoes contraidas."
       SKIP(1)
       
       "k) Diante de incapacidade civil  absoluta  ou relativa do(a) \033\105Cooperado(a)\033\106"
       SKIP
       "\033\105Titular\033\106, a  movimentacao  da  conta  corrente  sera realizada por meio de"
       SKIP
       "representacao ou assistencia  dos  representante(s) legal(is), conforme o"
       SKIP
       "caso."
       SKIP(1)
       
       "l) A \033\105Cooperativa\033\106 podera  disponibilizar  a seu criterio pacote de tarifas"
       SKIP
       "para a  movimentacao  da conta  corrente. Ao  aderir  o pacote de tarifas"
       SKIP
       "conforme  opcao  realizada em Termo  de Adesao proprio, o(a) \033\105Cooperado(a)\033\106"
       SKIP
       "\033\105Titular\033\106 autoriza o  debito  dos  valores correspondentes ao pacote, dire-"
       SKIP 
       "tamente desta conta."
       SKIP(1)
       
       "m) As partes declaram que este instrumento esta vinculado as  disposicoes" 
       SKIP
       "legais cooperativistas, ao Estatuto Social da \033\105Cooperativa\033\106 e  demais deli-"
       SKIP
       "beracoes  assembleares  desta, e  do  seu  Conselho de Administracao, aos"
       SKIP
       "quais  o(a) \033\105Cooperado(a)\033\106 e  os demais  titulares, livre e espontaneamente"
       SKIP
       "aderiram ao integrar o quadro social da \033\105Cooperativa\033\106, e cujo  teor ratifi-"
       SKIP
       "ca, reconhecendo neste contrato a celebracao de um  \033\105Ato Cooperativo\033\106."
       SKIP(1)       
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 110 
                            FRAME f_declara_1_pf.
                            
                            
 FORM  SKIP(3)
       tt-abert-decpf.dsmvtolt FORMAT "X(50)" SKIP(3)
       "______________________________" 
       SKIP(1)                               
       tt-abert-decpf.nmextttl FORMAT "x(40)"       
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN  WIDTH 80 
            FRAME f_declara_2_pf.

  FORM 
       SKIP(3)
       "______________________________       "
       tt-abert-decpf.linhater FORMAT "x(30)" 
       SKIP(1)
       tt-abert-decpf.nmsgdttl FORMAT "x(30)" 
       tt-abert-decpf.nmterttl FORMAT "x(30)"  AT 39
       WITH NO-LABEL NO-BOX COLUMN 6 SIDE-LABELS WIDTH 80 FRAME f_declara_2ttl.
  
  FORM 
       SKIP(3)
       "______________________________ "    
       SKIP(1)
       tt-abert-decpf.nmqtottl /*nmextttl*/ FORMAT "x(30)"
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN 
                                     WIDTH 80 FRAME f_declara_4ttl.
  
  FORM 
       SKIP(3)
       "______________________________ "
       SKIP(1)
       tt-abert-psfis.nmrepleg FORMAT "x(30)"
       SKIP(3)
       "______________________________" 
       SKIP(1)
       tt-abert-decpf.nmextcop FORMAT "x(55)"
  WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 80 FRAME f_declara_resp.
  
  FORM 
       SKIP(3)
       "______________________________" 
       SKIP(1)
       tt-abert-decpf.nmextcop FORMAT "x(55)"
       SKIP(3)
  WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 80 FRAME f_declara_resp_coop.
  
  FORM
       SKIP(18)
       "______________________________       ______________________________"
       SKIP(1)
       "Testemunha 1: ________________       Testemunha 2:________________ "
       SKIP(1)
       "CPF: ___.___.___-__                  CPF: ___.___.___-__        "
       SKIP(1)       
  WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 80 FRAME f_declara_test.

  
  FORM SKIP(7)
       "\033\105Autorizacao  para movimentacao de\033\106"
       "\033\105Autorizacao  para movimentacao de\033\106"    AT 42
       SKIP
       "\033\105conta   corrente  para  menor  de\033\106"
       "\033\105conta   corrente  para  menor  de\033\106"    AT 42
       SKIP
       "\033\105idade (12 a 16 anos  incompletos)\033\106"
       "\033\105idade (16 a 18 anos  incompletos)\033\106"    AT 42 
       SKIP
       "Na   qualidade   de   Responsavel"
       "Na   qualidade   de   Responsavel"                    AT 38
       SKIP
       "Legal  do  titular   desta conta,"                         
       "Legal  do  titular   desta conta,"                    AT 38
       SKIP
       "conta, AUTORIZO-O(A) a movimentar"
       "conta, AUTORIZO-O(A) a movimentar"                    AT 38
       SKIP
       "sua conta corrente,  como  se por"
       "isoladamente sua conta  corrente,"                    AT 38
       SKIP
       "mim    estivesse     pessoalmente" 
       "inclusive    requisitar  talao  e"                    AT 38
       SKIP
       "representado."
       "emitir   cheques,  como   se  por"                    AT 38   
       SKIP
       "mim    estivesse     pessoalmente"                    AT 38
       SKIP
       "representado."                                       AT 38
       SKIP(3)
       "     _____________________              _____________________"
       SKIP
       "       Responsavel Legal                  Responsavel Legal  "
       
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_ass_reponsavel_pf.
       
  /*  --------- PESSOA JURIDICA ---------  */
  
  FORM "\033\1051.2.Cooperada Titular:\033\106"
       tt-abert-psjur.nmprimtl FORMAT "x(40)"                 SKIP
       "Conta Corrente:"                                AT 16
       tt-abert-psjur.nrdconta FORMAT "x(10)"
       ", CNPJ:"
       tt-abert-psjur.nrcpfcgc FORMAT "x(18)"                 
       "\033\1051.3.Endereco:\033\106"
       tt-abert-psjur.dslinha1 FORMAT "x(61)"                 SKIP
       tt-abert-psjur.dslinha2 FORMAT "x(61)"      AT 15      
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_identificacao_pj.

  FORM SKIP(1)
       "\033\1052.DADOS COMPLEMENTARES:\033\106"
       SKIP
       "\033\1052.1.Natureza Juridica:\033\106"
       tt-abert-psjur.dsnatjur  FORMAT "x(15)"
       "\033\105,Inscricao Estadual:\033\106" 
       tt-abert-psjur.nrinsest  FORMAT "x(15)" 
       "\033\1052.2.Qualificacao dos Administradores:\033\106"
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_complem_pj_cabec.

  FORM "\033\105" 
       tt-abert-compj.dstitulo FORMAT "x(13)" AT 01
       "\033\106"
       tt-abert-compj.dsproftl FORMAT "x(58)" SKIP
       "CPF:"                                 AT 17
       tt-abert-compj.nrcpfcgc FORMAT "x(14)"                 
       ", RG:"
       tt-abert-compj.nrdocmto FORMAT "x(20)" SKIP
       "\033\105      Endereco:\033\106"
       tt-abert-compj.dslinha1 FORMAT "x(59)"       SKIP
       tt-abert-compj.dslinha2 FORMAT "x(59)" AT 17 SKIP
       tt-abert-compj.dslinha3 FORMAT "x(59)" AT 17
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 84 
                   FRAME f_complem_pj.
       
  FORM SKIP(1)
       "\033\1053.DECLARACOES \033\106"
       SKIP
       "A \033\105Cooperada\033\106  propoe  e  a \033\105Cooperativa\033\106 aceita  a  abertura  de  conta  cor-"
       SKIP
       "rente, declarando  em  carater  irrevogavel e  irretratavel, para todos os"
       SKIP
       "efeitos efeitos legais, que:"
       SKIP(1)
       
       "a) Esta  de   pleno acordo   com   as  disposicoes  contidas nas \033\105CLAUSULAS\033\106"       
       SKIP 
       "\033\105GERAIS     APLICAVEIS     AO     CONTRATO     DE     CONTA    CORRENTE   E\033\106"
       SKIP 
       "\033\105CONTA INVESTIMENTO\033\106, disponivel no  site da \033\105Cooperativa\033\106 (www.viacredi.coop."
       SKIP
       "br) e registrado no Cartorio de Registro de Titulos e Documentos da cidade"
       SKIP
       "de  Blumenau, sob n 99742, Livro B 340, Folha 005 em 13/11/2006, que inte-"
       SKIP
       "gram este  contrato, formando um documento unico e indivisivel, cuja copia"
       SKIP
       "recebe no ato da assinatura deste instrumento."       
       SKIP(1)       
       
       "b) As informacoes  e  elementos comprobatorios fornecidos para abertura da"
       SKIP
       "conta  corrente, constantes  na  ficha cadastral anexa, sao a expressao da"
       SKIP
       "verdade. Desde  ja  autoriza a \033\105Cooperativa\033\106 e  outras  instituicoes  finan-"
       SKIP
       "ceiras  parceiras, a  efetuar  consultas  cadastrais  junto ao CADIN, SPC,"
       SKIP
       "Serasa, Sistema de Informacoes  de Credito do Banco Central do Brasil-SCR,"
       SKIP
       "e demais bancos de dados que se fizerem necessarios a prestacao dos servi-"
       SKIP
       "cos financeiros  demandados pela \033\105Cooperada\033\106, nos termos do  previsto na Le-"
       SKIP
       "gislacao  vigente, podendo  enviar seus dados aos orgaos  publicos ou pri-"
       SKIP
       "vados, administradores de banco de dados, entre outros."
       SKIP(1)
       
       "Declara ainda estar ciente de que:"
       SKIP(1)
            
       "c) A conta aberta, sera movimentada por um ou mais socios, ou por procura-"
       SKIP 
       "dores legalmente constituidos, conforme  especificado  na ficha cadastral,"
       SKIP
       "podendo  estes  disporem  do  saldo  que nela existir, mediante emissao de"
       SKIP
       "cheques, recibos,  TEDs,  ordens  de pagamentos, ou quaisquer outros meios"
       SKIP
       "devidamente regulamentados pelo Banco Central do Brasil, podendo  inclusi-"
       SKIP
       "ve, realizar seu encerramento."
       SKIP(1)       
       
       "d) A \033\105Cooperativa\033\106 possui  parceria  com  outras  instituicoes para execucao"
       SKIP
       "dos servicos de Centralizacao da Compensacao de Cheques  e  Outros  Papeis"
       SKIP
       "(COMPE); Manutencao do Cadastro de Emitentes de Cheques sem Fundos; Siste-"
       SKIP
       "ma  de  Liquidacao   de  Pagamentos  e  Transferencias  Interbancarias  do"
       SKIP
       "Sistema Financeiro Nacional  e, para disponibilizacao de  Cartoes e Conve-"
       SKIP
       "nios  diversos, autorizando  para  a consecucao destes servicos, o repasse"
       SKIP
       "das informacoes cadastrais as instituicoes parceiras."
       SKIP(1)
       
       "e) Podera ter acesso aos  canais  de autoatendimento disponibilizados pela"
       SKIP
       "\033\105Cooperativa\033\106, ou  ainda, outros  que  venham a  ser  disponibilizados, para"
       SKIP
       "realizacao  de  movimentacoes, transacoes  e  contratacoes  financeiras em"
       SKIP
       "sua conta corrente. Atualmente, sao disponibilizados os seguintes canais:"
       SKIP(25)
       
       "f) Conta online: canal eletronico via internet, para acesso a  informacoes"
       SKIP
       "sobre  produtos  e  servicos da \033\105Cooperativa\033\106, podendo  realizar  consultas,"
       SKIP
       "movimentacoes, antecipacao  de  pagamento de contratos (observadas  as re-"
       SKIP
       "gras estipuladas para este servico), transacoes e  contratacoes, inclusive"
       SKIP
       "de  credito, diretamente  em sua conta. Na  liberacao  de  acesso da conta"
       SKIP
       "online, os  atos praticados  neste canal, serao realizados de acordo com o"
       SKIP
       "que dispuser os atos constitutivos da \033\105Cooperada\033\106 e  nos  limites de poderes"
       SKIP
       "de representacao  conferidos  aos  seus  representantes legais. No caso de"
       SKIP
       "representacao  por  uma  unica pessoa fisica, esta fara o uso de sua senha"
       SKIP
       "pessoal  e  intransferivel  para  realizacao  de todos os atos. No caso de"
       SKIP
       "representacao  por  duas  ou  mais pessoas fisicas, os  atos somente serao"
       SKIP
       "concluidos mediante confirmacao das operacoes e com senha pessoal de todos"
       SKIP
       "os   representantes   legais  da  \033\105Cooperada\033\106. E  de   responsabilidade   da"
       SKIP
       "\033\105Cooperada\033\106  os   atos   praticados   por   meio   deste   canal, ficando  a"
       SKIP
       "\033\105Cooperativa\033\106 isenta  de  qualquer  responsabilidade por eventuais prejuizos"
       SKIP
       "sofridos, inclusive  causados a  terceiros, decorrentes de atos praticados"
       SKIP
       "mediante a utilizaçao de senha pessoal."
       SKIP(1)
       
       "g) A \033\105Cooperada\033\106 podera  cadastrar  operador(es)  para  utilizacao  da conta"
       SKIP 
       "online, hipotese  em que  necessariamente  devera(ao) ser definida(s) a(s)"
       SKIP 
       "senha(s) e as permissoes  de acesso  para o(s) operador(es) cadastrado(s)."
       SKIP        
       "As  transacoes  financeiras  realizadas  pelo(s) operador(es) deverao  ser"
       SKIP 
       "aprovadas pelo(s) representante(s)  legal(is) da \033\105Cooperada\033\106, mediante aces-"
       SKIP 
       "so a conta online no site da \033\105Cooperativa\033\106. Nao havendo aprovacao, as opera-"
       SKIP 
       "coes serao canceladas e deverao ser novamente registradas e aprovadas."
       SKIP(1)
       
       "h) Aplicativo  para  celular: canal  para  acesso a conta, mediante uso da"
       SKIP
       "mesma  senha  de  utilizacao  da Conta Online, podendo realizar consultas,"
       SKIP
       "movimentacoes, transacoes  e  contratacoes  relativas  a produtos e servi-"
       SKIP
       "cos, inclusive  de  credito, diretamente em sua conta, conforme disponibi-"
       SKIP
       "lizado pela \033\105Cooperativa\033\106. "
       SKIP(1)
       
       "i) Terminal de autoatendimento: equipamento localizado nos Postos de Aten-"
       SKIP
       "dimento ou  em  outros locais de acesso publico, devidamente identificados"
       SKIP
       "com  as  credenciais  da \033\105Cooperativa\033\106, para  realizacao de consultas, movi-"
       SKIP
       "mentacoes, transacoes  e  contratacoes  relativas  a  produtos e servicos,"
       SKIP
       "inclusive de credito, diretamente na conta corrente."
       SKIP(1)
       
       "j) Sao disponibilizados  os servicos de Tele Saldo e SAC (Servico de Aten-"
       SKIP
       "dimento  ao  Cooperado), por  meio  de atendimento telefonico, para reali-"
       SKIP
       "zar consultas, obter informacoes, solicitar e autorizar transacoes, inclu-"
       SKIP
       "sive  as  relativas  a contratacao de produtos e servicos, ofertadas  pela"
       SKIP
       "\033\105Cooperativa\033\106, a qual reserva-se no  direito de, e a seu exclusivo criterio,"
       SKIP
       "disponibilizar novas  informacoes, operacoes e servicos, ou excluir quais-"
       SKIP
       "quer daqueles  ofertados na data da formalizacao da abertura da conta cor-"
       SKIP
       "rente. Por  medida de  seguranca fica a \033\105Cooperativa\033\106 autorizada  a realizar"
       SKIP
       "gravacoes das solicitacoes e instrucoes telefonicas."
       SKIP(1)
       
       "k) A \033\105Cooperativa\033\106 podera disponibilizar por meio dos canais  de autoatendi-"
       SKIP
       "mento  existentes, ou  ainda aqueles que  venham a ser criados, a possibi-"
       SKIP
       "lidade de  contratacao de operacao de credito, desde que os requisitos ne-"
       SKIP
       "cessarios para sua contratacao e  as  regras  estipuladas pela \033\105Cooperativa\033\106"
       SKIP
       "sejam observados. A \033\105Cooperada\033\106 declara-se  ciente  de  que e de sua inteira"
       SKIP
       "reponsabilidade o adimplemento das obrigacoes contraidas/contratacoes rea-"
       SKIP
       "lizadas em seu nome."
       SKIP(1)
       
       "l) A \033\105Cooperativa\033\106  podera  disponibilizar a  seu criterio pacote de tarifas"
       SKIP
       "para a movimentacao da  conta corrente. Ao aderir o pacote de tarifas con-"
       SKIP
       "forme opcao  realizada  em Termo de Adesao proprio, a \033\105Cooperada\033\106 autoriza o"
       SKIP
       "debito  dos valores correspondentes ao pacote, diretamente desta conta."
       SKIP(1)
       
       "m) A \033\105Cooperativa\033\106 possui  Politica  de  Responsabilidade  Socioambiental, a"
       SKIP
       "qual a \033\105Cooperada\033\106  declara  conhecer, cumprindo  e  respeitando,  durante a"
       SKIP
       "vigencia desta Proposta/Contrato de Abertura de Conta Corrente, o disposto"
       SKIP
       "na legislacao e a regulamentacao ambiental e trabalhista, especialmente as"
       SKIP
       "normas  relativas a seguranca e medicina do trabalho e ao Meio Ambiente, e"
       SKIP
       "a  inexistencia  de  trabalho que importe em incentivo a prostituicao, que"
       SKIP
       "utilize mao de obra infantil, que mantenha seus trabalhadores em condicoes"
       SKIP
       "analogas a escravidao ou que cause danos ao meio ambiente."
       SKIP(1)
       
       "n) Independentemente  de  culpa,  a  \033\105Cooperada\033\106  ressarcira  a  \033\105Cooperativa\033\106,"
       SKIP
	     "de  qualquer  quantia  que  esta  seja  compelido  a  pagar,  bem  como  a"
       SKIP
	     "indenizara  por  quaisquer  perdas e danos  referentes a danos  ambientais"
       SKIP
	     "ou  relativos  a  saude e seguranca  ocupacional que, de qualquer forma, a"
       SKIP
	     "autoridade entenda estar relacionados a utilizacao dos produtos e servicos"
       SKIP
	     "decorrentes desta Proposta/Contrato de Abertura de Conta Corrente."
       SKIP(1)
       
       "o) As  partes  declaram que este instrumento esta vinculado as disposicoes"
       SKIP
       "legais  cooperativistas, ao Estatuto Social da  \033\105Cooperativa\033\106 e demais deli-"
       SKIP
       "beracoes assembleares desta, e do seu Conselho de Administracao, aos quais"
       SKIP
       "a \033\105Cooperada\033\106, livre e espontaneamente aderiu ao integrar o quadro social da"
       SKIP
       "\033\105Cooperativa\033\106, e cujo teor  ratifica, reconhecendo neste contrato a celebra-"
       SKIP
       "cao de um \033\105Ato Cooperativo\033\106."
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 110 
                   FRAME f_declara_pj.
 
  FORM SKIP(3)
       tt-abert-decpj.dsmvtolt  FORMAT "X(50)"
       SKIP(27)       
       "______________________________       "
       SKIP(1)                               
       tt-abert-decpj.nmprimtl FORMAT "x(40)"
       SKIP(3)
       "______________________________       "
       SKIP(1)
       tt-abert-decpj.nmextcop FORMAT "x(40)"
       WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 80 
                   FRAME f_declara_pj2.

  FORM "Aguarde... Imprimindo proposta de abertura de conta-corrente"
       WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.
       
  HIDE MESSAGE NO-PAUSE.
  
  VIEW FRAME f_aguarde.
  PAUSE 2 NO-MESSAGE.
  HIDE FRAME f_aguarde NO-PAUSE.

  FIND FIRST tt-tprelato WHERE tt-tprelato.nmrelato = "ABERTURA" NO-ERROR.

  IF  AVAILABLE tt-tprelato THEN
      DO:
         IF  tt-tprelato.msgrelat <> "" THEN
             MESSAGE tt-tprelato.msgrelat.

         IF  tt-tprelato.flgbloqu THEN
             RETURN.
      END.
  
  OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84 APPEND.

  PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
           
  PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
  
  FIND FIRST tt-abert-ident NO-ERROR.
  
  DISPLAY STREAM str_1 
    tt-abert-ident.dstitulo WITH FRAME f_cabec.
    
  DISPLAY STREAM str_1  
    tt-abert-ident.nmextcop  
    tt-abert-ident.dslinha1  
    tt-abert-ident.dslinha2
    tt-abert-ident.dslinha3   
    WITH FRAME f_identificacao.  
  
  IF   tt-abert-ident.inpessoa = 1  THEN          /*   PESSOA FISICA   */
       DO:
          FIND FIRST tt-abert-psfis NO-ERROR.
          FIND FIRST tt-abert-compf NO-ERROR.
          FIND FIRST tt-abert-decpf NO-ERROR.

          DISPLAY STREAM str_1 
              tt-abert-psfis.nmprimtl   
              tt-abert-psfis.nrdconta     
              tt-abert-psfis.nrcpfcgc
              tt-abert-psfis.nrdocmto   
              tt-abert-psfis.dslinha1  
              tt-abert-psfis.dslinha2
              tt-abert-psfis.dsestcvl   
              WITH FRAME f_identificacao_pf.

          IF  tt-abert-psfis.nmrepleg <> "" THEN
              DISPLAY STREAM str_1 
                  tt-abert-psfis.nmrepleg
                  tt-abert-psfis.nrcpfrep    
                  tt-abert-psfis.nrdocrep
                  WITH FRAME f_representacao_pf.

          /* DISPLAY STREAM str_1 WITH FRAME f_complem_pf_cabec. */

          /* Segundo, Terceiro e Quarto Titular */
          FOR EACH tt-abert-compf:

              DISPLAY STREAM str_1 
                  tt-abert-compf.dstitulo    
                  tt-abert-compf.nmprimtl
                  tt-abert-compf.nrcpfcgc    
                  tt-abert-compf.nrdocmto
                  WITH FRAME f_complem_pf.

              DOWN STREAM str_1 WITH FRAME f_complem_pf.
          END.
       
          DISPLAY STREAM str_1  /* 
              tt-abert-decpf.dsclact1  
              tt-abert-decpf.dsclact2
              tt-abert-decpf.dsclact3  
              tt-abert-decpf.dsclact4
              tt-abert-decpf.dsclact5  
              tt-abert-decpf.dsclact6 */
              WITH FRAME f_declara_1_pf.

          DISPLAY STREAM str_1 
              tt-abert-decpf.dsmvtolt
              tt-abert-decpf.nmextttl               
              WITH FRAME f_declara_2_pf.

          IF  tt-abert-decpf.nmsgdttl <> ""  THEN
              DISPLAY STREAM str_1 
                             tt-abert-decpf.linhater
                             tt-abert-decpf.nmsgdttl  
                             tt-abert-decpf.nmterttl
                             WITH FRAME f_declara_2ttl.

          IF  tt-abert-decpf.nmqtottl <> ""  THEN
              DISPLAY STREAM str_1 
                             tt-abert-decpf.nmqtottl 
                             WITH FRAME f_declara_4ttl.

          IF  tt-abert-psfis.nmrepleg <> "" THEN
              DISPLAY STREAM str_1 
                  tt-abert-psfis.nmrepleg  
                  tt-abert-decpf.nmextcop
                  WITH FRAME f_declara_resp.
          ELSE
              DISPLAY STREAM str_1  
                  tt-abert-decpf.nmextcop
                  WITH FRAME f_declara_resp_coop.

          DISPLAY STREAM str_1 WITH FRAME f_declara_test.
          IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.
          DISPLAY STREAM str_1 WITH FRAME f_ass_reponsavel_pf.
       END.                    
  ELSE                     /*    PESSOA JURIDICA   */
       DO:

          FIND FIRST tt-abert-psjur NO-ERROR.
          FIND FIRST tt-abert-decpj NO-ERROR.

          DISPLAY STREAM str_1 
              tt-abert-psjur.nmprimtl    
              tt-abert-psjur.nrdconta     
              tt-abert-psjur.nrcpfcgc    
              tt-abert-psjur.dslinha1
              tt-abert-psjur.dslinha2 
              WITH FRAME f_identificacao_pj.

          DISPLAY STREAM str_1 
              tt-abert-psjur.dsnatjur  
              tt-abert-psjur.nrinsest
              WITH FRAME f_complem_pj_cabec.

          FOR EACH tt-abert-compj:

              DISPLAY STREAM str_1   
                  tt-abert-compj.dstitulo    
                  tt-abert-compj.dsproftl
                  tt-abert-compj.nrcpfcgc    
                  tt-abert-compj.nrdocmto    
                  tt-abert-compj.dslinha1  
                  tt-abert-compj.dslinha2 
                  tt-abert-compj.dslinha3 
                  WITH FRAME f_complem_pj.

              DOWN STREAM str_1 WITH FRAME f_complem_pj.
          END.
        
          DISPLAY STREAM str_1  
             /*  tt-abert-decpj.dsclact1  
              tt-abert-decpj.dsclact2
              tt-abert-decpj.dsclact3  
              tt-abert-decpj.dsclact4
              tt-abert-decpj.dsclact5  
              tt-abert-decpj.dsclact6 */
              WITH FRAME f_declara_pj.

          DISPLAY STREAM str_1 
              tt-abert-decpj.dsmvtolt
              tt-abert-decpj.nmprimtl
              tt-abert-decpj.nmextcop
              WITH FRAME f_declara_pj2. 

          DISPLAY STREAM str_1 WITH FRAME f_declara_test.

       END.
       
  OUTPUT STREAM str_1 CLOSE.
         
END.  /*  Procedure  p_abertura_nova   */

PROCEDURE Busca_Dados:

    DEF INPUT  PARAM par_tprelato AS CHARACTER   NO-UNDO.

    IF NOT VALID-HANDLE(h-b1wgen0063) THEN
        RUN sistema/generico/procedures/b1wgen0063.p PERSISTENT SET h-b1wgen0063.
    
    EMPTY TEMP-TABLE tt-tprelato.

    RUN Busca_TpRelatorio IN h-b1wgen0063
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT (NOT tel_tpimpres),
         OUTPUT TABLE tt-tprelato, 
         OUTPUT TABLE tt-erro ).
    
    RUN Busca_Impressao IN h-b1wgen0063
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_dtmvtolt,
          INPUT par_tprelato,
          INPUT (NOT tel_tpimpres),
         OUTPUT aux_msgalert,
         OUTPUT TABLE tt-abert-ident, 
         OUTPUT TABLE tt-abert-psfis,
         OUTPUT TABLE tt-abert-compf,
         OUTPUT TABLE tt-abert-decpf,
         OUTPUT TABLE tt-abert-psjur,
         OUTPUT TABLE tt-abert-compj,
         OUTPUT TABLE tt-abert-decpj,
         OUTPUT TABLE tt-termo-ident,
         OUTPUT TABLE tt-termo-assin,
         OUTPUT TABLE tt-termo-asstl,
         OUTPUT TABLE tt-finan-cabec,
         OUTPUT TABLE tt-finan-ficha,
         OUTPUT TABLE tt-fcad,
         OUTPUT TABLE tt-fcad-telef,
         OUTPUT TABLE tt-fcad-email,
         OUTPUT TABLE tt-fcad-psfis,
         OUTPUT TABLE tt-fcad-filia,
         OUTPUT TABLE tt-fcad-comer,
         OUTPUT TABLE tt-fcad-cbens,
         OUTPUT TABLE tt-fcad-depen,
         OUTPUT TABLE tt-fcad-ctato,
         OUTPUT TABLE tt-fcad-respl,
         OUTPUT TABLE tt-fcad-cjuge,
         OUTPUT TABLE tt-fcad-psjur,
         OUTPUT TABLE tt-fcad-regis,
         OUTPUT TABLE tt-fcad-procu,
         OUTPUT TABLE tt-fcad-bensp,
         OUTPUT TABLE tt-fcad-refer,    
         OUTPUT TABLE tt-erro ).

    DELETE OBJECT h-b1wgen0063.
    
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

END PROCEDURE.

FUNCTION BuscaPessoa RETURNS INTEGER:

    IF NOT VALID-HANDLE(h-b1wgen0063) THEN
        RUN sistema/generico/procedures/b1wgen0063.p 
        PERSISTENT SET h-b1wgen0063.

    RETURN INTEGER(DYNAMIC-FUNCTION("BuscaPessoa" IN h-b1wgen0063,
                                    INPUT glb_cdcooper,
                                    INPUT tel_nrdconta)).

END FUNCTION.


/* .......................................................................... */


