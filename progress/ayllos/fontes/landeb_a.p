/*..............................................................................

   Programa: fontes/landeb_a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Abril/2008                      Ultima atualizacao: 21/06/2018
   
   Dados referentes ao programa:

   Frequencia: Sempre que chamado pela tela LANDEB.
   Objetivo  : Mostrar opcao ON-LINE da tela LANDEB.

   Alteracoes: 24/06/2008 - Incluido critica para tabela crapatr (Gabriel).
               
               10/07/2008 - Comentada a critica para utilizacao do codigo de
                            historico 40 (Elton).
                            
               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela craphis(Guilherme).              

               23/11/2009 - Alteracao Codigo Historico (Kbase). 

               19/11/2010 - Acertar tipo lote do craplcm (Magui).
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               02/05/2011 - Atualizado campo cdoperad com o operador que
                            esta realizando a transacao (Adriano).
                            
               11/12/2013 - Inclusao de VALIDATE craplot e craplcm (Carlos)
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               21/06/2018 - P450 Regulatório de Credito - Substituido o create na craplcm pela chamada da rotina
                            gerar_lancamento_conta_comple. (Josiane Stiehler - AMcom)

.............................................................................*/

DEF STREAM str_1.
DEF STREAM str_2.

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF VAR tel_cdbccxlt        AS INT  FORMAT "zz9"                   NO-UNDO.
DEF VAR tel_nrdolote        AS INT  FORMAT "zzz,zz9"               NO-UNDO.
DEF VAR tel_cdhistor        AS INT  FORMAT "zzz9"                    NO-UNDO.
DEF VAR tel_nmarqint        AS CHAR FORMAT "x(40)"                 NO-UNDO.
DEF VAR tel_vllanmto        AS DEC  FORMAT "zzz,zzz,zzz,zz9.99"    NO-UNDO.
DEF VAR tel_nrdconta        AS INT  FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF VAR tel_dsimprim        AS CHAR FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF VAR tel_dscancel        AS CHAR FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.
DEF VAR tel_nrdocmto        AS DEC  FORMAT "zzz,zzz,zzz,zz9"       NO-UNDO.
DEF SHARED VAR tel_cdagenci AS INT  FORMAT "zz9"                   NO-UNDO.
DEF SHARED VAR tel_dtmvtolt AS DATE                                NO-UNDO.

DEF VAR aux_nmarqimp        AS CHAR                                NO-UNDO.
DEF VAR aux_nmendter        AS CHAR                                NO-UNDO.
DEF VAR aux_totdebit        AS INTEGER                             NO-UNDO.
DEF VAR aux_vlrdebit        AS DECIMAL                             NO-UNDO.
DEF VAR aux_vlrerros        AS DECIMAL                             NO-UNDO.
DEF VAR aux_toterros        AS INTEGER                             NO-UNDO.
DEF VAR aux_flgexist        AS LOGICAL                             NO-UNDO.
DEF VAR aux_flgerros        AS LOGICAL            INIT FALSE       NO-UNDO.
DEF VAR aux_flgescra        AS LOGICA                              NO-UNDO.
DEF VAR aux_dscomand        AS CHARACTER                           NO-UNDO.
DEF VAR aux_contador        AS INTEGER                             NO-UNDO.
DEF VAR aux_nmarqrem        AS CHAR FORMAT "x(40)"                 NO-UNDO.

DEF VAR par_flgrodar        AS LOGICAL                             NO-UNDO.
DEF VAR par_flgfirst        AS LOGICAL                             NO-UNDO.
DEF VAR par_flgcance        AS LOGICAL                             NO-UNDO.

DEF VAR aux_cdcritic        AS INTE                                NO-UNDO.
DEF VAR aux_dscritic        AS CHAR                                NO-UNDO.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.

FORM HEADER
     "DEPOSITOS A VISTA - DEBITADOS E NAO DEBITADOS (ERROS)"
     "Data:"              AT 59
     tel_dtmvtolt         AT 66
     SKIP(1)
     "CONTA"              AT 06
     "VALOR"              AT 28
     "CRITICA"            AT 35
     WITH NO-BOX PAGE-TOP SIDE-LABELS FRAME f_cab.

FORM tel_nrdconta         
     tel_vllanmto         AT 15
     glb_dscritic         AT 35
     WITH NO-BOX DOWN NO-LABEL WIDTH 80 FRAME f_rel.
     
FORM tel_nrdconta
     tel_vllanmto         AT 15
     "--DEBITADO--"       AT 35
     WITH NO-BOX DOWN NO-LABEL WIDTH 80 FRAME f_rel_debitado.
     
FORM SKIP(1) 
     "    DEBITADAS:" aux_totdebit  " Contas   VALOR:" aux_vlrdebit   SKIP
     "NAO DEBITADAS:" aux_toterros  " Contas   VALOR:" aux_vlrerros
     WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_totais.

FORM SKIP(1)
     tel_cdbccxlt AT 3  LABEL "Banco/Caixa" 
                        HELP  "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND(crapbcl WHERE
                                          crapbcl.cdbccxlt = tel_cdbccxlt),
                                          "057 - Banco nao cadastrado.")

     tel_nrdolote AT 28 LABEL "Lote"         
                        HELP  "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote <> 0 , 
                                 "357 - O campo deve ser prenchido")
                                  
     tel_cdhistor AT 50 LABEL "Historico"       AUTO-RETURN 
                        HELP  "Informe o codigo do historico"
                        VALIDATE(CAN-FIND(craphis WHERE 
                                          craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdhistor AND
                                          craphis.indebcre = "D"),
                                          "093 - Historico errado.")
     SKIP(5)
     tel_nmarqint AT 8  LABEL "Nome do arquivo" AUTO-RETURN
                        HELP  "Entre com o nome do arquivo"
     
     WITH NO-BOX COLUMN 2 ROW 9 OVERLAY SIDE-LABELS FRAME f_lanaut_nao_agendar.
 
FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel! " AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56 TITLE glb_nmformul
     FRAME f_atencao.
                        
FORM "Aguarde...Imprimindo relatorio!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

                                 
VIEW FRAME f_lanaut_nao_agendar.
PAUSE 0.
                               
ASSIGN glb_cdcritic = 0.

DO WHILE TRUE:
   
   ASSIGN tel_cdbccxlt  = 0
          tel_nrdolote  = 0
          aux_flgerros  = FALSE
          tel_cdbccxlt  = 100
          tel_nmarqint  =  ""
          aux_nmarqrem  = "".
   
        /* tirar o "_ux" do nome do arquivo */
   IF   tel_nmarqint <> ""              AND
        tel_nmarqint MATCHES "*_ux*"    THEN
        tel_nmarqint = SUBSTRING(tel_nmarqint,1,LENGTH(tel_nmarqint) - 3).
   
   DISPLAY tel_cdbccxlt WITH FRAME f_lanaut_nao_agendar.
   
   UPDATE tel_nrdolote 
          tel_cdhistor WITH FRAME f_lanaut_nao_agendar.
   
   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                      NO-LOCK NO-ERROR.
            
   /*** Comentado para nao criticar pagamento pelo BB ***
   DO WHILE TRUE:
      IF   crapcop.cdcrdarr <> 0   AND
           tel_cdhistor = 40       THEN
           DO:
               glb_cdcritic = 93. 
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
               ASSIGN tel_cdhistor = 585.
               UPDATE tel_cdhistor WITH FRAME f_lanaut_nao_agendar.
               NEXT.
           END.
      ELSE
           LEAVE.
   END.       
   *****************************************************/
   
   { includes/critica_numero_lote.i "tel_"}
          
   IF   glb_cdcritic <> 0   THEN
        DO:
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            BELL.
            glb_cdcritic = 0.
            NEXT.
        END.    

   UPDATE tel_nmarqint WITH FRAME f_lanaut_nao_agendar.

   IF   SEARCH (tel_nmarqint) = ?   THEN
        DO:
            glb_cdcritic = 182.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            PAUSE 1 NO-MESSAGE.
            HIDE MESSAGE.
            BELL.
            glb_cdcritic = 0.
            NEXT.
        END.
   
   ASSIGN aux_nmarqrem = tel_nmarqint.
   
   UNIX SILENT VALUE("dos2ux " + tel_nmarqint + " > " + tel_nmarqint + "_ux").
   
   tel_nmarqint = tel_nmarqint + "_ux".
   
   DO TRANSACTION:
       
      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = glb_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND
                         craplot.cdbccxlt = tel_cdbccxlt   AND
                         craplot.nrdolote = tel_nrdolote
                         NO-LOCK NO-ERROR.
  
      IF   AVAILABLE craplot   THEN
           DO:
               glb_cdcritic = 59.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
               RETURN.
           END.
   
      FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                         craphis.cdhistor = tel_cdhistor NO-LOCK NO-ERROR.
      
      IF   NOT AVAILABLE craphis   THEN
           DO:
               glb_cdcritic = 526.
               RUN fontes_critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
               RETURN.
           END.
               
      IF   craphis.tplotmov <> 1   THEN
           DO:
               glb_cdcritic = 062.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
               NEXT.
           END.
   
      IF   craphis.indebcre = "C"   THEN
           DO:
               glb_cdcritic = 093.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
               NEXT.
           END.   
    
      INPUT THROUGH basename `tty` NO-ECHO.
      SET aux_nmendter WITH FRAME f_terminal.
      INPUT CLOSE.
      
      aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                            aux_nmendter.
      
      UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
      ASSIGN aux_nmarqimp = "rl/" + STRING(tel_nrdolote,"999999") + 
                             STRING(TIME,"999999") + ".lst".
                             
      OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
      VIEW STREAM str_2 FRAME f_cab.
      
      INPUT STREAM str_1 FROM VALUE (tel_nmarqint) NO-ECHO.
      
      DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO,LEAVE:
      
         SET STREAM str_1 tel_nrdconta tel_nrdocmto tel_vllanmto.
        
         IF   tel_nrdconta = 999999   THEN
              LEAVE.
      
         ASSIGN glb_cdcritic = 0
                aux_flgexist = FALSE.

         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.
                            
         IF   NOT AVAILABLE crapass   THEN
              DO:
                  glb_cdcritic = 9.
                  RUN critica.
                  NEXT.
              END.
                                 /*
         IF   crapass.dtdemiss <> ?   THEN
              DO:
                  glb_cdcritic = 075.
                  RUN critica.
                  NEXT.
              END.    
                                   */
         IF   craphis.inautori = 1   THEN
              DO:
                  FIND crapatr WHERE crapatr.cdcooper = glb_cdcooper   AND
                                     crapatr.nrdconta = tel_nrdconta   AND
                                     crapatr.cdhistor = tel_cdhistor   AND
                                     crapatr.cdrefere = tel_nrdocmto
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE crapatr   THEN
                       DO:
                           glb_cdcritic = 446.
                           RUN critica.
                           NEXT.
                       END.
              END.
         
         IF   CAN-FIND(craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                                     craplcm.dtmvtolt = tel_dtmvtolt   AND
                                     craplcm.cdagenci = tel_cdagenci   AND
                                     craplcm.cdbccxlt = tel_cdbccxlt   AND
                                     craplcm.nrdolote = tel_nrdolote   AND
                                     craplcm.nrdctabb = tel_nrdconta   AND
                                     craplcm.nrdocmto = tel_nrdocmto    
                                     USE-INDEX craplcm1)   THEN
              DO:                       
                  glb_cdcritic = 92.
                  RUN critica.
                  NEXT.
              END.

         ASSIGN aux_flgexist = TRUE.
         RUN debita.
         
         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote   NO-ERROR.

         IF   NOT AVAILABLE craplot   THEN
              DO:
                  CREATE craplot.
                  ASSIGN craplot.cdcooper = glb_cdcooper
                         craplot.dtmvtolt = tel_dtmvtolt
                         craplot.cdagenci = tel_cdagenci
                         craplot.cdbccxlt = tel_cdbccxlt
                         craplot.nrdolote = tel_nrdolote
                         craplot.cdoperad = glb_cdoperad
                         craplot.tplotmov = 1
                         craplot.cdoperad = glb_cdoperad
                         craplot.cdhistor = tel_cdhistor
                         craplot.dtmvtopg = tel_dtmvtolt.

                  VALIDATE craplot.

              END.           
                  
         /* P450 - Regulatório de Crédito */
         /* BLOCO DA INSERÇAO DA CRAPLCM */
         IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
             RUN sistema/generico/procedures/b1wgen0200.p 
         PERSISTENT SET h-b1wgen0200.         
         
         /* Criar o registro de credito do Salario */
         RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                    (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
                    ,INPUT craplot.cdagenci               /* par_cdagenci */
                    ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
                    ,INPUT craplot.nrdolote               /* par_nrdolote */
                    ,INPUT tel_nrdconta                   /* par_nrdconta */
                    ,INPUT tel_nrdocmto                   /* par_nrdocmto */
                    ,INPUT tel_cdhistor                   /* par_cdhistor */
                    ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                    ,INPUT tel_vllanmto                   /* par_vllanmto */
                    ,INPUT tel_nrdconta                   /* par_nrdctabb */
                    ,INPUT ""                             /* par_cdpesqbb */
                    ,INPUT 0                              /* par_vldoipmf */
                    ,INPUT 0                              /* par_nrautdoc */
                    ,INPUT 0                              /* par_nrsequni */
                    ,INPUT 0                              /* par_cdbanchq */
                    ,INPUT 0                              /* par_cdcmpchq */
                    ,INPUT 0                              /* par_cdagechq */
                    ,INPUT 0                              /* par_nrctachq */
                    ,INPUT 0                              /* par_nrlotchq */
                    ,INPUT 0                              /* par_sqlotchq */
                    ,INPUT ""                             /* par_dtrefere */
                    ,INPUT ""                             /* par_hrtransa */
                    ,INPUT craplot.cdoperad               /* par_cdoperad */
                    ,INPUT ""                             /* par_dsidenti */
                    ,INPUT glb_cdcooper                   /* par_cdcooper */
                    ,INPUT STRING(tel_nrdconta,"99999999")/* par_nrdctitg */
                    ,INPUT ""                             /* par_dscedent */
                    ,INPUT 0                              /* par_cdcoptfn */
                    ,INPUT 0                              /* par_cdagetfn */
                    ,INPUT 0                              /* par_nrterfin */
                    ,INPUT 0                              /* par_nrparepr */
                    ,INPUT 0                              /* par_nrseqava */
                    ,INPUT 0                              /* par_nraplica */
                    ,INPUT 0                              /* par_cdorigem */
                    ,INPUT 0                              /* par_idlautom */
                    /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
                    ,INPUT 0                              /* Processa lote                                 */
                    ,INPUT 0                              /* Tipo de lote a movimentar                     */
                    /* CAMPOS DE SAÍDA                                                                     */                                            
                    ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                    ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                    ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                    ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
          
         IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            DO:  
              glb_cdcritic = aux_cdcritic.
              glb_dscritic = aux_dscritic.
              MESSAGE glb_dscritic.
              BELL.
              glb_cdcritic = 0.
              PAUSE 2 NO-MESSAGE.
              RETURN.
            END.   
  
         IF  VALID-HANDLE(h-b1wgen0200) THEN
             DELETE PROCEDURE h-b1wgen0200.
         
         ASSIGN
                craplot.nrseqdig = craplot.nrseqdig + 1
                craplot.qtcompln = craplot.qtcompln + 1
                craplot.qtinfoln = craplot.qtcompln

                craplot.vlcompdb = craplot.vlcompdb + tel_vllanmto
                craplot.vlinfodb = craplot.vlcompdb.
      
      END. /* Fim do DO WHILE TRUE */
   
   END. /* Fim da TRANSACTION */
                
   DISPLAY STREAM str_2 aux_toterros aux_totdebit aux_vlrdebit
                        aux_vlrerros WITH FRAME f_totais.

   INPUT STREAM str_1 CLOSE.
   OUTPUT STREAM str_2 CLOSE.
   
   IF   aux_flgerros   THEN
        MESSAGE "Houveram erros, verifique o relatorio" VIEW-AS ALERT-BOX.
   ELSE
        MESSAGE "Operacao efetuada com sucesso!" VIEW-AS ALERT-BOX.
        
   ASSIGN glb_nrdevias = 1
          par_flgrodar = TRUE.
          
   VIEW FRAME f_aguarde.
   PAUSE 3 NO-MESSAGE.
   HIDE FRAME f_aguarde NO-PAUSE.
   
   { includes/impressao.i }
   
   UNIX SILENT VALUE ("rm " + tel_nmarqint + " 2> /dev/null").
   UNIX SILENT VALUE ("rm " + aux_nmarqrem + " 2> /dev/null").
     
   LEAVE.

END.   /* Fim do DO WHILE TRUE */

PROCEDURE critica:
  
    IF   LINE-COUNTER(str_2)  > (PAGE-SIZE(str_2)) - 4   THEN
         DO:
             PAGE STREAM str_2.
             VIEW STREAM str_2 FRAME f_cab.
         END.
             
    RUN fontes/critic.p.

    DISPLAY STREAM str_2
            tel_nrdconta tel_vllanmto glb_dscritic WITH FRAME f_rel.

    DOWN STREAM str_2 WITH FRAME f_rel.
            
    ASSIGN glb_cdcritic = 0
           aux_flgerros = TRUE
           aux_toterros = aux_toterros + 1
           aux_vlrerros = aux_vlrerros + tel_vllanmto.

END PROCEDURE.
           
PROCEDURE debita:

    IF  LINE-COUNTER(str_2) > (PAGE-SIZE(str_2)) - 4   THEN
        DO:
            PAGE STREAM str_2.
            VIEW STREAM str_2 FRAME f_cab.
        END.
    
    DISPLAY STREAM str_2
            tel_nrdconta tel_vllanmto WITH FRAME f_rel_debitado.
            
    DOWN STREAM str_2 WITH FRAME f_rel_debitado.
            
    ASSIGN aux_totdebit = aux_totdebit + 1
           aux_vlrdebit = aux_vlrdebit + tel_vllanmto.

END PROCEDURE.
           
/*............................................................................*/
