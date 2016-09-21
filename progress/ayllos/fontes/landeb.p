/* .............................................................................

   Programa: fontes/landeb.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Julho/2004                      Ultima atualizacao: 24/11/2015
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANDEB.
   
   Alteracoes: 04/07/2005 - Alimentado campo cdcooper das tabelas craplau
                            e crapavs (Diego).
                            
               17/08/2005 - Permitir somente historicos de debito (Evandro).
               
               25/08/2005 - Zerada variavel glb_cdcritic(Mirtes)

               10/12/2005 - Atualiza craplau.nrdctitg (Magui).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 

               04/04/2008 - Incluida opcao AGENDAR/ON-LINE, chamar 
                            programa landeb_a.p (Gabriel).
               16/06/2008 - Retirado os comentarios da Magui no histor 585
                            (Rosangela)     
                            
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "Can-Find e find" da tabela
                            CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               10/07/2008 - Comentada a critica que nao permite a utilizacao do
                            historico 40 (Elton).
               
               01/09/2008 - Descomentada critica que nao permitia a utilizacao
                            do historico 40 (Elton).
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               23/11/2009 - Alteracao Codigo Historico (Kbase). 
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 

               02/05/2011 - Atualizado campo cdoperad com o operador que
                            esta realizando a transacao (Adriano).
                            
               15/03/2012 - Sera permitido apenas historicos com inhistor = 11
                            (Adriano).             

               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
               
               10/12/2013 - Inclusao de VALIDATE craplau e crapavs (Carlos)
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               24/11/2015 - Retirada de message com datas (Carlos)
............................................................................. */

DEF STREAM str_1.                        
DEF STREAM str_2.

{ includes/var_online.i } 

DEF        NEW SHARED VAR   tel_dtmvtolt AS DATE FORMAT "99/99/9999"  NO-UNDO.
DEF        NEW SHARED VAR   tel_cdagenci AS INT  FORMAT "zz9"         NO-UNDO.
DEF        VAR tel_nmarqint AS CHAR    FORMAT "x(40)"                 NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT     FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_cdhistor AS INT     FORMAT "zzz9"                  NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF        VAR tel_nrdocmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9"       NO-UNDO.
DEF        VAR tel_vllanaut AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"    NO-UNDO.
DEF        VAR tel_cdbccxpg AS INT     FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"                NO-UNDO.
DEF        VAR tel_dtmvtopg AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.
DEF        VAR tel_cddopcao AS LOGICAL FORMAT "AGENDAR/ON-LINE"       NO-UNDO.

DEF        VAR aux_dtultdia AS DATE                                   NO-UNDO.
DEF        VAR aux_flgexist AS LOGICAL                                NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL               INIT FALSE       NO-UNDO.
DEF        VAR aux_nmendter AS CHAR                                   NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                                NO-UNDO.
DEF        VAR aux_dscomand AS CHARACTER                              NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                   NO-UNDO.
DEF        VAR aux_contador AS INTEGER                                NO-UNDO.
DEF        VAR aux_dsimprim AS CHARACTER                              NO-UNDO.
DEF        VAR aux_cdempres AS INT                                    NO-UNDO.

DEF        VAR par_flgrodar AS LOGICAL                                NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL                                NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                                NO-UNDO.

FORM HEADER 
     "LANCAMENTOS AUTOMATICOS - RELATORIO DE ERROS"
     "Data:"             AT 59   
     tel_dtmvtolt        AT 66 
     SKIP(1)
     WITH NO-BOX PAGE-TOP SIDE-LABELS FRAME f_cab.

FORM tel_nrdconta                LABEL "CONTA"
     tel_vllanaut       AT 15    LABEL "VALOR"
     glb_dscritic       AT 35    LABEL "CRITICA"
     WITH NO-BOX DOWN NO-LABEL WIDTH 80 FRAME f_rel.

FORM SKIP(3)
     tel_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                  HELP  "Entre com a opcao desejada (A)GENDAR, (O)N-LINE."
     
     tel_cdagenci AT 29 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o numero do PA."
                        VALIDATE(CAN-FIND(crapage WHERE
                                          crapage.cdcooper = glb_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci),
                                          "962 - PA nao cadastrado.")
     tel_dtmvtolt AT 50 LABEL "Data"
     
     SKIP(11)
     WITH ROW 4 WIDTH 80 OVERLAY SIDE-LABELS TITLE glb_tldatela 
     FRAME f_lanaut.
     
FORM 
     tel_cdbccxlt AT 3  LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND(crapbcl WHERE 
                                          crapbcl.cdbccxlt = tel_cdbccxlt), 
                                          "057 - Banco nao cadastrado.")

     tel_nrdolote AT 28 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(CAN-FIND(craplot WHERE 
                                    craplot.cdcooper = glb_cdcooper        AND
                                    craplot.dtmvtolt = tel_dtmvtolt        AND
                                    craplot.cdagenci = INPUT tel_cdagenci  AND
                                    craplot.cdbccxlt = INPUT tel_cdbccxlt  AND
                                    craplot.nrdolote = INPUT tel_nrdolote),
                                    "058 - Numero do lote errado.")
     
     tel_cdhistor AT 50 LABEL "Historico" AUTO-RETURN
                        HELP "Informe o codigo do historico"
                        VALIDATE(CAN-FIND(craphis WHERE
                                          craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdhistor AND
                                          craphis.inhistor = 11), 
                                          "093 - Historico errado.")
     
     SKIP(1)
     tel_dtmvtopg AT 3  LABEL  "Pagamento" AUTO-RETURN
                        HELP "Entre com a data do pagamento."
                        VALIDATE(CAN-FIND(craplot WHERE
                                    craplot.cdcooper = glb_cdcooper        AND 
                                    craplot.dtmvtopg = tel_dtmvtopg        AND
                                    craplot.cdagenci = INPUT tel_cdagenci  AND
                                    craplot.cdbccxlt = INPUT tel_cdbccxlt  AND
                                    craplot.nrdolote = INPUT tel_nrdolote),
                                    "013 - Data errada.")

     tel_cdbccxpg AT 28 LABEL "Banco para pagamento" AUTO-RETURN
                        HELP "Entre com o codigo do banco de pagamento."
                        VALIDATE(CAN-FIND(crapban WHERE 
                                          crapban.cdbccxlt = tel_cdbccxpg), 
                                          "057 - Banco nao cadastrado.")
       
     SKIP(3)
     tel_nmarqint AT  8 LABEL "Nome do arquivo" format "x(40)"
                        HELP "Entre com o nome do arquivo"
     
     WITH NO-BOX COLUMN 2 ROW 10 OVERLAY WIDTH 65 SIDE-LABELS 
     FRAME f_lanaut_agenda.
                             
FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM "Aguarde... Imprimindo relatorio de erros!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.


VIEW FRAME f_lanaut. 

PAUSE 0. 
glb_cddopcao = "L".
glb_cdcritic = 0.

DO WHILE TRUE:
       
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      ASSIGN aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                              YEAR(glb_dtmvtolt)) + 4) -
                              DAY(DATE(MONTH(glb_dtmvtolt),28,
                              YEAR(glb_dtmvtolt)) + 4))
             aux_flgerros = false
             tel_dtmvtolt = glb_dtmvtolt
             tel_cdagenci = 0
             tel_cddopcao = TRUE.
             
           /* tira o "_ux" do nome do arquivo */
      IF   tel_nmarqint <> ""             AND
           tel_nmarqint MATCHES "*_ux*"   THEN
      
           tel_nmarqint = SUBSTRING(tel_nmarqint,1,LENGTH(tel_nmarqint) - 3).
      
      DISPLAY tel_dtmvtolt
              tel_cdagenci
              WITH FRAME f_lanaut.

      UPDATE tel_cddopcao WITH FRAME f_lanaut.
   
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO: 
            RUN fontes/novatela.p.
            
            IF   CAPS(glb_nmdatela) <> "LANDEB"   THEN
                 DO:
                     HIDE FRAME f_lanaut.
                     RETURN.               
                 END.
            ELSE
                 NEXT.
        END.
   ELSE
        { includes/acesso.i }
 
   UPDATE tel_cdagenci WITH FRAME f_lanaut.
   
        /* AGENDAR */
   IF   tel_cddopcao   THEN  
        
        DO WHILE TRUE:
        
            UPDATE tel_cdbccxlt tel_nrdolote tel_cdhistor
                   WITH FRAME f_lanaut_agenda.
            
            FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                               NO-LOCK NO-ERROR.
            
            DO WHILE TRUE:
               IF   crapcop.cdcrdarr <>  0   AND
                    tel_cdhistor = 40        THEN
                    DO:
                        glb_cdcritic = 93.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        BELL.
                        glb_cdcritic = 0.
                        ASSIGN tel_cdhistor = 585.
                        UPDATE tel_cdhistor WITH FRAME f_lanaut_agenda.
                        NEXT.
                    END.
               ELSE
                    LEAVE. 
            END.
                        
            UPDATE tel_dtmvtopg 
                   tel_cdbccxpg 
                   tel_nmarqint WITH FRAME f_lanaut_agenda.
  
            IF   SEARCH(tel_nmarqint) = ?   THEN 
                 DO:
                     glb_cdcritic = 182.
                     RUN fontes/critic.p.
                     MESSAGE glb_dscritic.
                     BELL.
                     glb_cdcritic = 0.            
                     NEXT.
                 END.

            UNIX SILENT VALUE("dos2ux " + tel_nmarqint + " > " + 
                               tel_nmarqint + "_ux").
             
            tel_nmarqint = tel_nmarqint + "_ux".
   
            DO TRANSACTION:

               DO aux_contador = 1 TO 10:
      
                  FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                                     craplot.dtmvtolt = tel_dtmvtolt   AND
                                     craplot.cdagenci = tel_cdagenci   AND
                                     craplot.cdbccxlt = tel_cdbccxlt   AND
                                     craplot.nrdolote = tel_nrdolote   
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 

                  IF   NOT AVAILABLE craplot   THEN
                       DO: 
                           IF   LOCKED craplot   THEN
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    glb_cdcritic = 84.
                                    RUN fontes/critic.p.
                                    MESSAGE glb_dscritic.
                                    BELL.
                                    NEXT.
                                END.
                           ELSE
                                DO:
                                    glb_cdcritic = 60.
                                    RUN fontes/critic.p.
                                    MESSAGE glb_dscritic.
                                    BELL.
                                    LEAVE.
                                END.
                       END.
                  ELSE
                       IF   craplot.tplotmov <> 12   THEN
                            DO:
                                glb_cdcritic = 132.
                                RUN fontes/critic.p.
                                MESSAGE glb_dscritic.
                                BELL.
                                LEAVE.
                            END.
      
               END. /* Fim do DO .. TO */
      
               IF   glb_cdcritic > 0   THEN
                    NEXT.
                                                  
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
      
               IF   craphis.indebfol <> 1   THEN
                    IF   craphis.tplotmov <> 1     OR  
                         craphis.indebcre <> "D"   OR
                         craphis.inhistor <> 11    OR
                         craphis.indebcta <> 1     THEN
                         DO:
                             glb_cdcritic = 94.
                             RUN fontes/critic.p.
                             MESSAGE glb_dscritic.
                             BELL.
                             glb_cdcritic = 0.
                             PAUSE.
                             NEXT.
                         END.
               ELSE
                    IF   tel_dtmvtopg > aux_dtultdia   THEN
                         DO:
                             glb_cdcritic = 13.
                             RUN fontes/critic.p.
                             MESSAGE glb_dscritic.
                             BELL.
                             glb_cdcritic = 0.
                             RETURN.
                         END.

               tel_nrseqdig = 1.

               INPUT THROUGH basename `tty` NO-ECHO.
               SET aux_nmendter WITH FRAME f_terminal.
               INPUT CLOSE.    
               
               aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                     aux_nmendter.

               UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
               ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + 
                                      STRING(TIME) + ".ex".

               OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp).
               VIEW STREAM str_2 FRAME f_cab.
   
               INPUT STREAM str_1 FROM VALUE(tel_nmarqint)  NO-ECHO.

               DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

                  SET STREAM str_1 tel_nrdconta tel_nrdocmto tel_vllanaut.
   
                  IF   tel_nrdconta = 999999   THEN
                       LEAVE.
   
                  ASSIGN glb_cdcritic = 0
                         aux_flgexist = False.

                  FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                     crapass.nrdconta = tel_nrdconta 
                                     NO-LOCK NO-ERROR.

                  IF   AVAILABLE crapass  THEN
                       DO:
                           IF  crapass.inpessoa = 1   THEN 
                               DO:
                                   FIND crapttl WHERE 
                                        crapttl.cdcooper = glb_cdcooper     AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = 1 
                                        NO-LOCK NO-ERROR.
                
                                   IF   AVAIL crapttl  THEN
                                        ASSIGN aux_cdempres = crapttl.cdempres.
                               END.
                           ELSE
                               DO:
                                   FIND crapjur WHERE 
                                        crapjur.cdcooper = glb_cdcooper  AND
                                        crapjur.nrdconta = crapass.nrdconta
                                        NO-LOCK NO-ERROR.
                
                                   IF   AVAIL crapjur  THEN
                                        ASSIGN aux_cdempres = crapjur.cdempres.
                               END.
                       END.

                  IF   NOT AVAILABLE crapass   THEN  
                       DO:
                           glb_cdcritic = 9.
                           RUN critica.
                           NEXT.
                       END.
                
                  IF   CAN-DO("2,4,5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                       DO:
                           FIND FIRST craptrf WHERE 
                                      craptrf.cdcooper = glb_cdcooper     AND
                                      craptrf.nrdconta = crapass.nrdconta AND
                                      craptrf.tptransa = 1
                                      USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                           IF   NOT AVAILABLE craptrf THEN  
                                DO:
                                    glb_cdcritic = 95.
                                    RUN critica.
                                    NEXT.
                                END.
                           ELSE
                                DO:
                                    ASSIGN aux_flgexist = TRUE
                                           tel_nrdconta = craptrf.nrsconta.
                                    NEXT.
                                END.
                       END.

                  IF   aux_flgexist AND glb_cdcritic = 0  THEN  
                       DO:
                           glb_cdcritic = 156.
                           RUN critica.
                           NEXT.
                       END.
   
                  IF   craphis.inautori = 1   THEN
                       DO:    
                           FIND crapatr WHERE 
                                crapatr.cdcooper = glb_cdcooper   AND 
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

                           IF   crapatr.dtfimatr <> ?   THEN 
                                DO:
                                    glb_cdcritic = 447.
                                    RUN critica.
                                    NEXT.
                                END.
                       END.
   
                  IF   craphis.indebfol = 1   THEN  
                       DO:  
                           /*FIND crapemp OF crapass NO-LOCK NO-ERROR.*/
                           FIND crapemp WHERE 
                                crapemp.cdcooper = glb_cdcooper AND
                                crapemp.cdempres = aux_cdempres
                                NO-LOCK NO-ERROR.

                           IF   NOT AVAILABLE crapemp   THEN
                                DO:
                                    glb_cdcritic = 40.
                                    RUN critica.
                                    NEXT.
                                END.                    
                           ELSE
                                DO:
                                    IF   crapemp.tpdebemp <> 2   THEN
                                         DO:
                                             glb_cdcritic = 445.
                                             NEXT-PROMPT tel_cdhistor
                                             WITH FRAME f_lanaut_agenda.
                                             RUN critica.
                                             LEAVE.
                                         END.
                     
                                    IF   crapemp.inavsemp <> 0   THEN
                                         DO:
                                             glb_cdcritic = 507.
                                             NEXT-PROMPT tel_cdhistor
                                             WITH FRAME f_lanaut_agenda.
                                             RUN critica.
                                             LEAVE.
                                         END.
                                END.      
                       END.
        
                  IF   CAN-FIND(craplau WHERE 
                                craplau.cdcooper = glb_cdcooper   AND 
                                craplau.dtmvtolt = tel_dtmvtolt   AND
                                craplau.cdagenci = tel_cdagenci   AND
                                craplau.cdbccxlt = tel_cdbccxlt   AND
                                craplau.nrdolote = tel_nrdolote   AND
                                craplau.nrdctabb = tel_nrdconta   AND
                                craplau.nrdocmto = tel_nrdocmto
                                USE-INDEX craplau1)   THEN
                       DO:
                           glb_cdcritic = 92.    
                           RUN critica.        
                           NEXT.
                       END.

                  IF   CAN-FIND(crapavs WHERE 
                                crapavs.cdcooper = glb_cdcooper       AND 
                                crapavs.dtmvtolt = tel_dtmvtolt       AND
                                crapavs.cdempres = 0                  AND
                                crapavs.cdagenci = crapass.cdagenci   AND
                                crapavs.cdsecext = crapass.cdsecext   AND
                                crapavs.nrdconta = tel_nrdconta       AND
                                crapavs.dtdebito = tel_dtmvtopg       AND
                                crapavs.cdhistor = tel_cdhistor       AND
                                crapavs.nrdocmto = tel_nrdocmto  
                                USE-INDEX crapavs1)   THEN
                       DO:
                           glb_cdcritic = 622.  
                           RUN critica.
                           NEXT.
                       END.
                                  
                  IF   crapass.dtdemiss <> ?   THEN 
                       DO:
                           glb_cdcritic = 449.
                           RUN critica.
                           NEXT.
                       END. 
                                    
                  FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper AND 
                                     crapsld.nrdconta = crapass.nrdconta 
                                     NO-LOCK NO-ERROR.
        
                  IF   crapsld.dtdsdclq <> ?   THEN 
                       DO:
                           glb_cdcritic = 633.
                           RUN critica.
                            NEXT.
                       END.
         
                  CREATE craplau.
                  ASSIGN craplau.dtmvtolt = craplot.dtmvtolt
                         craplau.cdagenci = craplot.cdagenci
                         craplau.cdbccxlt = craplot.cdbccxlt
                         craplau.nrdolote = craplot.nrdolote
                         craplau.nrdconta = tel_nrdconta
                         craplau.nrdctabb = tel_nrdconta 
                         craplau.nrdctitg = STRING(tel_nrdconta,"99999999")    
                         craplau.vllanaut = tel_vllanaut
                         craplau.cdhistor = tel_cdhistor
                         craplau.nrseqdig = craplot.nrseqdig + 1
                         craplau.nrdocmto = tel_nrdocmto
                         craplau.cdbccxpg = tel_cdbccxpg
                         craplau.dtmvtopg = tel_dtmvtopg
                         craplau.tpdvalor = 1
                         craplau.insitlau = IF craphis.indebfol = 1 
                                               THEN 3 
                                            ELSE 1
                         craplau.cdcritic = 0
                         craplau.dtdebito = ?
                         craplau.nrcrcard = 0
                         craplau.nrseqlan = 0
                         craplau.cdcooper = glb_cdcooper
                         craplot.cdoperad = glb_cdoperad 
                         craplot.nrseqdig = craplot.nrseqdig + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.qtinfoln = craplot.qtcompln.
                  
                  VALIDATE craplau.

                  ASSIGN tel_nrseqdig = craplau.nrseqdig.

                  IF   craphis.indebcre = "D"   THEN
                       ASSIGN craplot.vlcompdb = craplot.vlcompdb + tel_vllanaut
                              craplot.vlinfodb = craplot.vlcompdb.
                  ELSE
                       IF   craphis.indebcre = "C"   THEN
                            ASSIGN craplot.vlcompcr = craplot.vlcompcr + 
                                                      tel_vllanaut
                                   craplot.vlinfocr = craplot.vlcompcr.

                  IF   craphis.inavisar = 1   THEN
                       DO:                      
                           CREATE crapavs.
                           ASSIGN crapavs.cdagenci = crapass.cdagenci
                                  crapavs.cdsecext = crapass.cdsecext
                                  crapavs.cdhistor = craplau.cdhistor
                                  crapavs.nrdconta = craplau.nrdconta
                                  crapavs.nrdocmto = craplau.nrdocmto
                                  crapavs.vllanmto = craplau.vllanaut
                                  crapavs.nrseqdig = craplau.nrseqdig
                                  crapavs.vldebito = 0
                                  crapavs.vlestdif = 0
                                  crapavs.insitavs = 0
                                  crapavs.flgproce = FALSE
                                  crapavs.cdcooper = glb_cdcooper.

                           IF   craphis.indebfol = 1   THEN
                                ASSIGN crapavs.tpdaviso = 1
                                       crapavs.dtdebito = ?
                                       crapavs.cdempres = aux_cdempres
                                       crapavs.dtrefere = tel_dtmvtopg
                                       crapavs.dtmvtolt = IF crapemp.tpconven =1
                                                             THEN  
                                                                crapemp.dtavsemp
                                                          ELSE  aux_dtultdia.
                           ELSE
                                ASSIGN crapavs.tpdaviso = 2
                                       crapavs.dtdebito = craplau.dtmvtopg
                                       crapavs.cdempres = 0
                                       crapavs.dtrefere = craplau.dtmvtolt
                                       crapavs.dtmvtolt = craplau.dtmvtolt.

                           VALIDATE crapavs.

                       END.
                   
               END.  /*  Fim do DO WHILE TRUE  */

            END.   /* Fim da transacao */

            INPUT STREAM str_1 CLOSE.
            OUTPUT STREAM str_2 CLOSE.

            IF   aux_flgerros   THEN   
                 DO:
                     MESSAGE "Houveram erros, verifique o relatorio de erros"
                     VIEW-AS ALERT-BOX.
                     
                     ASSIGN glb_nrdevias = 1
                            par_flgrodar = TRUE.

                     VIEW FRAME f_aguarde.
                     PAUSE 3 NO-MESSAGE.
                     HIDE FRAME f_aguarde NO-PAUSE.
       
                     { includes/impressao.i } 
                 END.
            ELSE
                 MESSAGE "Operacao efetuada com sucesso!" VIEW-AS ALERT-BOX.
          
            UNIX SILENT VALUE("rm " + tel_nmarqint + " 2> /dev/null").
                     
            LEAVE.
        
        END. /* Fim da opcao AGENDAR  */
   
             
   ELSE /* ON-LINE */
        RUN fontes/landeb_a.p.
END.

PROCEDURE critica:
    
    IF   LINE-COUNTER(str_2) > 80  THEN
         DO:
             PAGE STREAM str_2.
             VIEW STREAM str_2 FRAME f_cab.
         END.
    
    RUN fontes/critic.p.                                             
    DISPLAY STREAM str_2 
            tel_nrdconta tel_vllanaut glb_dscritic WITH FRAME f_rel.
    DOWN STREAM str_2 WITH FRAME f_rel.
    glb_cdcritic = 0.
    aux_flgerros = true.

END PROCEDURE.
/* .......................................................................... */
