/* .............................................................................

   Programa: fontes/lancre.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Fevereiro/2006                    Ultima atualizacao: 22/06/2018 
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCRE.
   
   Alteracoes: 07/01/2008 - Modificado nome do relatorio (Diego).
   
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find e CAN-FIND" da tabela
                            CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.

               08/07/2009 - Acerto na chamada da include impressao.i (David).

               23/11/2009 - Alteracao Codigo Historico (Kbase). 
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 

               02/05/2011 - Atualizado campo cdoperad com o operador que
                            esta realizando a transacao (Adriano).        
                            
               15/03/2012 - Sera permitido apenas historicos com inhistor = 1
                            (Adriano).
                            
               08/07/2013 - Nao aceitar valor de lancamento zerado (Ze).
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               09/12/2013 - Inclusao de VALIDATE craplot e craplcm (Carlos)
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               22/06/2018 - Alteraçao Tratamento de Históricos de Credito/Debito - Fabiano B. Dias AMcom        

............................................................................. */

DEF STREAM str_1.                        
DEF STREAM str_2. /* Relatorio */


{ includes/var_online.i } 
{ sistema/generico/includes/b1wgen0200tt.i }


DEF        VAR tel_nmarqint AS CHAR    FORMAT "x(60)"                 NO-UNDO.
DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT     FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_cdhistor AS INT     FORMAT "zzz9"                  NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF        VAR tel_nrdocmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9"       NO-UNDO.
DEF        VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"    NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.

DEF        VAR aux_flgexist AS LOGICAL                                NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL               INIT FALSE       NO-UNDO.
DEF        VAR aux_nmendter AS CHAR                                   NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                                NO-UNDO.
DEF        VAR aux_dscomand AS CHARACTER                              NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                   NO-UNDO.
DEF        VAR aux_nmarqcre AS CHAR                                   NO-UNDO.
DEF        VAR aux_contador AS INTEGER                                NO-UNDO.
DEF        VAR aux_dsimprim AS CHARACTER                              NO-UNDO.
DEF        VAR aux_toterros AS INT                                    NO-UNDO.
DEF        VAR aux_totcredi AS INT                                    NO-UNDO.
DEF        VAR aux_vlrerros AS DECIMAL                                NO-UNDO.
DEF        VAR aux_vlrcredi AS DECIMAL                                NO-UNDO.

DEF        VAR par_flgrodar AS LOGICAL                                NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL                                NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                                NO-UNDO.

/* 22/06/2018 - gerar_lancamento */
DEF        VAR h-b1wgen0200 AS HANDLE                                 NO-UNDO.
DEF        VAR aux_incrineg AS INT                                    NO-UNDO.
DEF        VAR aux_cdcritic AS INT                                    NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                   NO-UNDO.

FORM HEADER 
     "DEPOSITOS A VISTA - CREDITADOS E NAO CREDITADOS(ERROS)"
     "Data:"             AT 59   
     tel_dtmvtolt        AT 66 
     SKIP(1)
     "ARQUIVO:"          
     tel_nmarqint        
     SKIP(1)
     "CONTA"             AT 06
     "VALOR"             AT 28
     "CRITICA"           AT 35 
     WITH NO-BOX PAGE-TOP SIDE-LABELS FRAME f_cab.

FORM tel_nrdconta                 
     tel_vllanmto        AT 15    
     glb_dscritic        AT 35    
     WITH NO-BOX DOWN NO-LABEL WIDTH 80 FRAME f_rel.
     
FORM tel_nrdconta                 
     tel_vllanmto        AT 15    
     "--CREDITADO--"     AT 35
     WITH NO-BOX DOWN NO-LABEL WIDTH 80 FRAME f_rel_creditado.

FORM SKIP(1)
     "    CREDITADAS:" aux_totcredi  " Contas   VALOR:" aux_vlrcredi   SKIP
     "NAO CREDITADAS:" aux_toterros  " Contas   VALOR:" aux_vlrerros
     WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_totais.

FORM SKIP(3)
     tel_dtmvtolt AT  3 LABEL "Data"

     tel_cdagenci AT 30 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o numero do PA."
                        VALIDATE(CAN-FIND(crapage WHERE 
                                          crapage.cdcooper = glb_cdcooper   AND
                                          crapage.cdagenci = tel_cdagenci), 
                                          "962 - PA nao cadastrado.")
     SKIP(3)
     tel_cdbccxlt AT  3 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND(crapbcl WHERE 
                                          crapbcl.cdbccxlt = tel_cdbccxlt), 
                                          "057 - Banco nao cadastrado.")

     tel_nrdolote AT 28 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE (tel_nrdolote <> 0 ,
                                     "375 - O campo deve ser preenchido")

     tel_cdhistor AT 50 LABEL "Historico" AUTO-RETURN
                        HELP "Informe o codigo do historico"
                        VALIDATE(CAN-FIND(craphis WHERE 
                                          craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdhistor AND
                                          craphis.inhistor = 1), 
                                          "093 - Historico errado.")

     SKIP(3)
     tel_nmarqint AT  8 LABEL "Nome do arquivo" format "x(40)"
                        HELP "Entre com o nome do arquivo"
     SKIP(4)
     WITH ROW 4 COLUMN 1 WIDTH 80 OVERLAY SIDE-LABELS 
          TITLE glb_tldatela FRAME f_lanaut.
                             
FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM "Aguarde... Imprimindo relatorio!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

VIEW FRAME f_lanaut.
PAUSE 0. 

ASSIGN glb_cddopcao = "L"
       glb_cdcritic = 0.

DO WHILE TRUE:
       
   RUN fontes/inicia.p.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO: 
            RUN fontes/novatela.p.
            
            IF   CAPS(glb_nmdatela) <> "LANCRE"   THEN
                 DO:
                     HIDE FRAME f_lanaut.
                     RETURN.               
                 END.
            ELSE
                 NEXT.
        END.
   ELSE
        { includes/acesso.i }
 
   ASSIGN aux_flgerros = FALSE
          tel_dtmvtolt = glb_dtmvtolt.
   
   /* tira o "_ux" do nome do arquivo */
   IF   tel_nmarqint <> ""             AND
        tel_nmarqint MATCHES "*_ux*"   THEN
        tel_nmarqint = SUBSTRING(tel_nmarqint,1,LENGTH(tel_nmarqint) - 3). 

   ASSIGN tel_cdbccxlt = 100. 

   DISPLAY tel_dtmvtolt 
           tel_cdbccxlt
           WITH FRAME f_lanaut.
    
   UPDATE tel_cdagenci 
          tel_nrdolote 
          tel_cdhistor 
          tel_nmarqint 
          WITH FRAME f_lanaut.
  
   { includes/critica_numero_lote.i "tel_" }

   IF   glb_cdcritic <> 0   THEN
        DO:
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            BELL.
            glb_cdcritic = 0.            
            NEXT.
        END. 

   IF   SEARCH(tel_nmarqint) = ?   THEN 
        DO:
            glb_cdcritic = 182.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            BELL.
            glb_cdcritic = 0.            
            NEXT.
        END.

   ASSIGN aux_nmarqcre = tel_nmarqint + "_ux".
   
   UNIX SILENT VALUE("dos2ux " + tel_nmarqint + " > " + aux_nmarqcre).

   DO TRANSACTION:
           
      FIND craplot NO-LOCK WHERE 
           craplot.cdcooper = glb_cdcooper   AND
           craplot.dtmvtolt = tel_dtmvtolt   AND
           craplot.cdagenci = tel_cdagenci   AND
           craplot.cdbccxlt = tel_cdbccxlt   AND
           craplot.nrdolote = tel_nrdolote  NO-ERROR.
     
      IF   AVAILABLE  craplot THEN
           DO:
               glb_cdcritic = 59.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
               RETURN.
           END.
      
      FIND craphis WHERE 
           craphis.cdcooper = glb_cdcooper AND
           craphis.cdhistor = tel_cdhistor NO-LOCK NO-ERROR.
      
      IF   NOT AVAILABLE craphis   THEN  
           DO:
               glb_cdcritic = 526.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
               RETURN.
           END.
  
      IF   craphis.tplotmov <> 1    THEN
           DO:
               glb_cdcritic = 062.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
               NEXT.
           END.
        
      IF   craphis.indebcre = "D"   THEN
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

      ASSIGN aux_nmarqimp = "rl/0" + STRING(tel_nrdolote,"999999") +
                            STRING(TIME,"999999") + ".lst".

      OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp)  PAGE-SIZE 84.
      
      VIEW STREAM str_2 FRAME f_cab.

      INPUT STREAM str_1 FROM VALUE(aux_nmarqcre) NO-ECHO.

      DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
         
         SET STREAM str_1
             tel_nrdconta tel_nrdocmto tel_vllanmto.
   
         IF   tel_nrdconta = 999999   THEN
              LEAVE.
   
         ASSIGN glb_cdcritic = 0
                aux_flgexist = FALSE.

         IF   tel_vllanmto = 0 THEN
              DO:
                  glb_cdcritic = 269.
                  RUN critica.
                  NEXT.
              END.
         
         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE crapass   THEN  
              DO:
                  glb_cdcritic = 9.
                  RUN critica.
                  NEXT.
              END.
                         
         IF   crapass.dtdemiss <> ?   THEN 
              DO:
                  glb_cdcritic = 075.
                  RUN critica.
                  NEXT.
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
         
         RUN credita.
                            
         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote NO-ERROR.
         
         IF   NOT AVAILABLE craplot THEN          
              DO:
                  CREATE craplot.
                  ASSIGN craplot.cdcooper = glb_cdcooper      
                         craplot.dtmvtolt = tel_dtmvtolt       
                         craplot.cdagenci = tel_cdagenci      
                         craplot.cdbccxlt = tel_cdbccxlt       
                         craplot.nrdolote = tel_nrdolote
                         craplot.cdoperad = glb_cdoperad
                         craplot.tplotmov = 1.
                  VALIDATE craplot.
              END.
                     
           IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
               RUN sistema/generico/procedures/b1wgen0200.p 
                   PERSISTENT SET h-b1wgen0200.
  
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
            ,INPUT 0                              /* par_dsidenti */
            ,INPUT glb_cdcooper                   /* par_cdcooper */
            ,STRING(tel_nrdconta,"99999999")      /* par_nrdctitg */
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
  
            IF  VALID-HANDLE(h-b1wgen0200) THEN
                DELETE PROCEDURE h-b1wgen0200. 
			
            IF aux_cdcritic > 0 OR 	aux_dscritic <> "" THEN 
            DO:
              ASSIGN glb_cdcritic = aux_cdcritic.
                     glb_dscritic = aux_dscritic.    
              NEXT.
            END.


                ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                craplot.qtcompln = craplot.qtcompln + 1
                craplot.qtinfoln = craplot.qtcompln  

                craplot.vlcompcr = craplot.vlcompcr + tel_vllanmto
                craplot.vlinfocr = craplot.vlcompcr.
                              
      END.  /*  Fim do DO WHILE TRUE  */
      
   END.  /* Fim da transacao */

   DISPLAY STREAM str_2 aux_toterros aux_totcredi aux_vlrcredi
                        aux_vlrerros WITH FRAME f_totais.

   INPUT STREAM str_1 CLOSE.
   
   OUTPUT STREAM str_2 CLOSE.

   UNIX SILENT VALUE("mv " + tel_nmarqint + " salvar 2> /dev/null").

   UNIX SILENT VALUE("rm " + aux_nmarqcre + " 2> /dev/null").
      
   IF   aux_flgerros   THEN   
        MESSAGE "Houveram erros, verifique o relatorio" VIEW-AS ALERT-BOX.
   ELSE
        MESSAGE "Operacao efetuada com sucesso!" VIEW-AS ALERT-BOX.

   ASSIGN glb_nrdevias = 1
          par_flgrodar = TRUE.

   VIEW FRAME f_aguarde.
   PAUSE 3 NO-MESSAGE.
   HIDE FRAME f_aguarde NO-PAUSE.

   /** FIND FIRST necessario para a include impressao.i **/
   FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
   { includes/impressao.i }

   LEAVE.
        
END.

PROCEDURE critica:
    
    IF   LINE-COUNTER(str_2) > (PAGE-SIZE(str_2)) - 4  THEN
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

PROCEDURE credita:

    IF   LINE-COUNTER(str_2) > (PAGE-SIZE(str_2)) - 4  THEN
         DO:
             PAGE STREAM str_2.
             VIEW STREAM str_2 FRAME f_cab.
         END.
        
    DISPLAY STREAM str_2 
            tel_nrdconta tel_vllanmto WITH FRAME f_rel_creditado.

    DOWN STREAM str_2 WITH FRAME f_rel_creditado.
    
    ASSIGN aux_totcredi = aux_totcredi + 1
           aux_vlrcredi = aux_vlrcredi + tel_vllanmto.

END PROCEDURE. 

/* .......................................................................... */
