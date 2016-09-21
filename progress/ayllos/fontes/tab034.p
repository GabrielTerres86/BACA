/* ............................................................................

   Programa: fontes/tab034.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Janeiro/2005                    Ultima atualizacao: 08/01/2015
             
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB034.
   
   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
     
               06/02/2006 - Inclusao de NO-UNDO nas temp-tables - SQLWorks -
                            Eder
                            
               10/01/2007 - Somente permite cooperativas  utilizar  opcao "C"
                            exceto  para os operadores 1, 799 e 997 (Elton).
                            
               05/10/2007 - Nao permite que primeira faixa tenha valor
                            diferente de zero durante a inclusao (Elton).

               09/12/2008 - Incluir opcao "M" (David).
          
               10/02/2009 - Liberar o ope. 979 (Gabriel)   
               
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               05/02/2014 - Inclusao de replicação de dados e registros p/
                            Poupança Programada. (Jean Michel)
               
               21/07/2014 - Inclusao da opcao "PCAPTA" na opcao "M", projeto de
                            captação. (Jean Michel)
                            
               04/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               03/12/2014 - Alterado para remover registro da craptrd ao utilizar
                            a opcao "E". (Reinert)
 
               08/01/2015 - Inclusao de log para alteracao da opcao PCAPTA
                            (Jean Michel).
............................................................................ */

{ includes/var_online.i }

DEF VAR tel_tpaplica LIKE craprda.tpaplica                          NO-UNDO.

DEF VAR aux_qtdtaxas AS INTE                                        NO-UNDO.
DEF VAR aux_dsdfaixa AS CHAR                                        NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                       NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                        NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR tel_dsaplica AS CHAR    FORMAT "x(20)"                      NO-UNDO.
DEF VAR tel_flgrdmpp AS LOGI    FORMAT "Sim/Nao"                    NO-UNDO.
DEF VAR tel_flgrdc30 AS LOGI    FORMAT "Sim/Nao"                    NO-UNDO.
DEF VAR tel_flgrdc60 AS LOGI    FORMAT "Sim/Nao"                    NO-UNDO.
DEF VAR tel_flgrdpre AS LOGI    FORMAT "Sim/Nao"                    NO-UNDO.
DEF VAR tel_flgrdpos AS LOGI    FORMAT "Sim/Nao"                    NO-UNDO.
DEF VAR tel_flgpcapt AS LOGI    FORMAT "Sim/Nao"                    NO-UNDO.

DEF VAR log_flgrdmpp AS LOGI                                        NO-UNDO.
DEF VAR log_flgpcapt AS LOGI                                        NO-UNDO.
DEF VAR log_flgrdc30 AS LOGI                                        NO-UNDO.
DEF VAR log_flgrdc60 AS LOGI                                        NO-UNDO.
DEF VAR log_flgrdpre AS LOGI                                        NO-UNDO.
DEF VAR log_flgrdpos AS LOGI                                        NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                        NO-UNDO.
DEF VAR par_loginusr AS CHAR                                        NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                        NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                        NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                        NO-UNDO.
DEF VAR par_numipusr AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.

DEF VAR aux_vlinifxa AS DECI                                        NO-UNDO.

DEF TEMP-TABLE w_taxas                                              NO-UNDO
    FIELD tpaplica  AS INT
    FIELD dsaplica  AS CHAR
    FIELD vlinifxa  AS DECIMAL  FORMAT "zzz,zz9.99"
    FIELD vlfimfxa  AS DECIMAL  FORMAT "zzz,zzz,zz9.99"
    FIELD vldataxa  AS DECIMAL  FORMAT "zz9.999999"
    FIELD taxadano  AS DECIMAL  FORMAT "zz9.999999".
    
DEF QUERY q_taxas FOR w_taxas.
                                                      
DEF BROWSE b_taxas QUERY q_taxas
    DISPLAY w_taxas.dsaplica  COLUMN-LABEL "TIPO"       FORMAT "x(11)"
            SPACE(6)
            w_taxas.vlinifxa  COLUMN-LABEL "DE"
            SPACE(6)
            w_taxas.vlfimfxa  COLUMN-LABEL "ATE"
            SPACE(7)
            w_taxas.vldataxa  COLUMN-LABEL "TAXA (%CDI)"
            SPACE(7)
            WITH 11 DOWN NO-BOX.

DEF BUFFER w_taxas2 FOR w_taxas.
    

FORM SKIP(1)
     glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, I ou M)."
                        VALIDATE(CAN-DO("A,C,E,I,M",glb_cddopcao),
                                        "014 - Opcao errada.")
                                       
     tel_tpaplica AT 20 LABEL "Tipo da Aplicacao"
          HELP  "Informe o tipo (0-TODAS / 1-RDCA30 / 2-POUP.PROGR. / 3-RDCA60)"
          VALIDATE(INPUT tel_tpaplica >= 0 AND INPUT tel_tpaplica < 4,
                   "269 - Valor errado.")
     SKIP(1)
     b_taxas            HELP "Use as SETAS para navegar / F4 para sair"
     WITH SIDE-LABELS ROW 4 WIDTH 80 TITLE glb_tldatela FRAME f_taxas.

FORM SKIP(1)
     tel_dsaplica AT  8 LABEL "Tipo"
     SKIP(2)
     tel_flgpcapt AT  8 LABEL "0 -    PCAPTA"
     tel_flgrdc60 AT 35 LABEL "3 -    RDCA60"
     SKIP(1)
     tel_flgrdc30 AT  8 LABEL "1 -    RDCA30"
     tel_flgrdpre AT 35 LABEL "7 -    RDCPRE"    
     SKIP(1)
     tel_flgrdmpp AT  8 LABEL "2 - POUP.PROG"
     tel_flgrdpos AT 35 LABEL "8 -    RDCPOS"
     SKIP(1)
     
     SKIP(1)
     WITH FRAME f_acumula ROW 8 OVERLAY SIDE-LABELS CENTERED
                          WIDTH 62 TITLE "ACUMULA CAPTACAO".

ON RETURN OF b_taxas DO:

    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN aux_vlinifxa = w_taxas.vlinifxa.
    
    IF   glb_cddopcao = "C"   THEN
         LEAVE.
    ELSE
    IF   glb_cddopcao = "I"   THEN
         RUN opcao_i.
    ELSE
    IF   glb_cddopcao = "E"   THEN
         RUN opcao_e.
    ELSE             
    IF   glb_cddopcao = "A"   THEN
         RUN opcao_a.        

    RUN carrega_taxas.       

    CLOSE QUERY q_taxas.
    OPEN  QUERY q_taxas FOR EACH w_taxas WHERE 
                                 w_taxas.tpaplica = tel_tpaplica   OR
                                (tel_tpaplica = 0 AND glb_cddopcao = "C").

END.

DO WHILE TRUE: 

    ASSIGN glb_cddopcao = "C"
           tel_tpaplica = 0.

    RUN fontes/inicia.p.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        HIDE b_taxas IN FRAME f_taxas.
    
        UPDATE glb_cddopcao WITH FRAME f_taxas.
        
        IF   glb_cddopcao <> "C"   THEN
             DO:
                 IF  glb_dsdepart <> "TI"                   AND
                     glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
                     glb_dsdepart <> "PRODUTOS"             AND
                     glb_dsdepart <> "COORD.PRODUTOS"       THEN      
                     DO:
                         glb_cdcritic = 36.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         NEXT.
                     END.
             END.
        
        LEAVE.    
    
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
             IF   glb_nmdatela <> "TAB034"   THEN
                  DO:
                      HIDE FRAME f_taxas.
                      RETURN.
                  END.
             ELSE
                  NEXT.
         END.

    IF   aux_cddopcao <> glb_cddopcao   THEN
         DO:
             { includes/acesso.i }
             aux_cddopcao = glb_cddopcao.
         END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
        /* Cumulatividade somente para aplicacoes RDCA60 */
        IF   glb_cddopcao = "M"  THEN
             DO:
                 ASSIGN tel_tpaplica = 3.
                 DISPLAY tel_tpaplica WITH FRAME f_taxas.
                 PAUSE(0).
             END.
        ELSE     
             UPDATE tel_tpaplica WITH FRAME f_taxas.
                 
        LEAVE.
                
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
         NEXT.
         
    IF   tel_tpaplica = 0 AND glb_cddopcao <> "C"   THEN
         DO:
             MESSAGE 'Tipo de aplicacao = 0 (TODAS) somente eh possivel na'
                     'opcao "C"'.
             NEXT.
         END.
                  
    IF   glb_cddopcao = "M"   THEN
         DO:
             ASSIGN tel_flgpcapt = FALSE
                    tel_flgrdc30 = FALSE
                    tel_flgrdmpp = FALSE
                    tel_flgrdc60 = FALSE
                    tel_flgrdpre = FALSE
                    tel_flgrdpos = FALSE.

             FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                    craptab.nmsistem = "CRED"       AND
                                    craptab.cdempres = tel_tpaplica AND
                                    craptab.tptabela = "GENERI"     AND
                                    craptab.cdacesso = "SOMAPLTAXA" NO-LOCK:

                 IF   craptab.tpregist = 0   THEN
                      DO:
                          IF   craptab.dstextab = "SIM"   THEN
                               tel_flgpcapt = TRUE.
                          ELSE
                               tel_flgpcapt = FALSE.
                      END.

                 IF   craptab.tpregist = 1   THEN
                      DO:
                          IF   craptab.dstextab = "SIM"   THEN
                               tel_flgrdc30 = TRUE.
                          ELSE
                               tel_flgrdc30 = FALSE.
                      END.
           
                 IF   craptab.tpregist = 2   THEN
                      DO:
                          IF   craptab.dstextab = "SIM"   THEN
                               tel_flgrdmpp = TRUE.
                          ELSE
                               tel_flgrdmpp = FALSE.
                      END.
               
                 IF   craptab.tpregist = 3   THEN
                      DO:
                          IF   craptab.dstextab = "SIM"   THEN
                               tel_flgrdc60 = TRUE.
                          ELSE
                               tel_flgrdc60 = FALSE.
                      END.
                                
                 IF   craptab.tpregist = 7   THEN
                      DO:
                          IF   craptab.dstextab = "SIM"   THEN
                               tel_flgrdpre = TRUE.
                          ELSE
                               tel_flgrdpre = FALSE.
                      END.
           
                 IF   craptab.tpregist = 8  THEN
                      DO:
                          IF   craptab.dstextab = "SIM"   THEN
                               tel_flgrdpos = TRUE.
                          ELSE
                               tel_flgrdpos = FALSE.
                      END.
      
             END. /* Fim do FOR EACH craptab */

             ASSIGN tel_dsaplica = STRING(tel_tpaplica) + " - " +
                                  (IF   tel_tpaplica = 1   THEN
                                        "RDCA30"  
                                   ELSE
                                   IF   tel_tpaplica = 2   THEN
                                        "POUP.PROGRAMADA"
                                   ELSE
                                        "RDCA60")
                    log_flgpcapt = tel_flgpcapt
                    log_flgrdc30 = tel_flgrdc30 
                    log_flgrdmpp = tel_flgrdmpp 
                    log_flgrdc60 = tel_flgrdc60 
                    log_flgrdpre = tel_flgrdpre
                    log_flgrdpos = tel_flgrdpos.
                                                      
             DISPLAY tel_dsaplica WITH FRAME f_acumula.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                 UPDATE tel_flgpcapt tel_flgrdc30 tel_flgrdmpp tel_flgrdc60 
                        tel_flgrdpre tel_flgrdpos WITH FRAME f_acumula.

                 LEAVE.
                 
             END.

             IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                  DO:
                      HIDE FRAME f_acumula NO-PAUSE.
                      NEXT.
                  END.
                 
             RUN confirma.
                 
             IF   aux_confirma <> "S"   THEN
                  DO:
                      glb_cdcritic = 0.
                      HIDE FRAME f_acumula NO-PAUSE.
                      NEXT.
                  END.    
                 
             RUN proc_acumula.
                  
             HIDE FRAME f_acumula NO-PAUSE.     
         END.
    ELSE
         DO:
             RUN carrega_taxas.
    
             CLOSE QUERY q_taxas.
             OPEN  QUERY q_taxas 
                   FOR EACH w_taxas WHERE 
                            w_taxas.tpaplica = tel_tpaplica   OR
                            (tel_tpaplica = 0 AND glb_cddopcao = "C").
         
             UPDATE b_taxas WITH FRAME f_taxas.
         END.
END.

PROCEDURE opcao_i.
        
    /* ultima faixa/taxa */
    DEF VAR tel_iniulfxa AS DECIMAL     FORMAT "zzz,zz9.99"         NO-UNDO.
    DEF VAR tel_fimulfxa AS DECIMAL     FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
    DEF VAR tel_vldultxa AS DECIMAL     FORMAT "zz9.999999"         NO-UNDO.
    
    DEF VAR aux_prifaixa AS LOGICAL  INIT FALSE                     NO-UNDO.
    
    FORM SKIP(1)
         "ULTIMA FAIXA/TAXA" AT  3
         SKIP
         tel_iniulfxa          AT  3  LABEL "De"
         tel_fimulfxa          AT 25  LABEL "Ate"
         tel_vldultxa          AT 48  LABEL "Taxa"
         SKIP(2)
         "NOVA FAIXA/TAXA"     AT  3
         SKIP
         w_taxas.vlinifxa      AT  3  LABEL "De"
                                      HELP "Informe o valor Inicial da Faixa"
         "Ate: 999.999.999,99" AT 25
         w_taxas.vldataxa      AT 48  LABEL "Taxa"
                                      HELP "Informe o valor (%) da Taxa"
         SKIP(1)
         WITH ROW 10 CENTERED SIDE-LABELS OVERLAY WIDTH 68
              TITLE " Inclusao de Nova Faixa/Taxa " FRAME f_opcao_i.
    
    /* mostra a ultima faixa/taxa */
  
    FIND LAST w_taxas WHERE w_taxas.tpaplica = tel_tpaplica NO-LOCK NO-ERROR.
    
    IF   AVAILABLE w_taxas   THEN
         ASSIGN tel_iniulfxa = w_taxas.vlinifxa
                tel_fimulfxa = w_taxas.vlfimfxa
                tel_vldultxa = w_taxas.vldataxa.
    ELSE 
         ASSIGN aux_prifaixa = TRUE.    
    
    DISPLAY tel_iniulfxa
            tel_fimulfxa
            tel_vldultxa
            WITH FRAME f_opcao_i.

    CREATE w_taxas.
    UPDATE w_taxas.vlinifxa 
           w_taxas.vldataxa
           WITH FRAME f_opcao_i.
    
    /** Nao perimite quea a primeira faixa tenha valor diferente de zero **/
    IF  aux_prifaixa = TRUE THEN
        IF  w_taxas.vlinifxa <> 0 THEN
            DO: 
                MESSAGE 
                   "Primeira faixa nao pode ter valor diferente de '0'(zero).".
                BELL.
                NEXT.
            END.
    /* validacao da nova faixa */
   
    FIND FIRST w_taxas2 WHERE w_taxas2.tpaplica = tel_tpaplica       AND
                              w_taxas2.vlinifxa = w_taxas.vlinifxa
                              NO-LOCK NO-ERROR.
                              
    /* verifica se ja existe essa faixa */
    IF   AVAILABLE w_taxas2   THEN
         DO:
             MESSAGE "Ja existe uma faixa com esse valor inicial.".
             NEXT.
         END.
    ELSE        /* verifica se a taxa (porcentagem) esta correta */
         DO:
    
             FIND FIRST w_taxas2 WHERE w_taxas2.tpaplica = tel_tpaplica   AND
                                       w_taxas2.vlinifxa > w_taxas.vlinifxa
                                       NO-LOCK NO-ERROR.
                                       
             IF   AVAILABLE w_taxas2   THEN
                  DO:
                     IF   w_taxas.vldataxa >= w_taxas2.vldataxa   THEN
                          DO:
                             MESSAGE "Valor da taxa errado.".
                             NEXT.
                          END.
                  END.
                                                   
             FIND LAST w_taxas2 WHERE w_taxas2.tpaplica = tel_tpaplica   AND
                                       w_taxas2.vlinifxa < w_taxas.vlinifxa
                                       NO-LOCK NO-ERROR.
                                       
             IF   AVAILABLE w_taxas2   THEN
                  DO:
                      IF   w_taxas.vldataxa <= w_taxas2.vldataxa   THEN
                           DO:
                               MESSAGE "Valor da taxa errado.".
                               NEXT.
                           END.
                  END.
         END.
    
    ASSIGN w_taxas.tpaplica = tel_tpaplica
           w_taxas.dsaplica = IF w_taxas.tpaplica = 1 THEN
                                 "RDCA30"
                              ELSE
                              IF w_taxas.tpaplica = 2 THEN
                                 "POUP.PROGR."
                              ELSE
                                 "RDCA60"
           w_taxas.vlfimfxa = 999999999.99
           w_taxas.taxadano = 0.
           
    RUN prepara_atualizacao.

    DO aux_contador = 1 TO 10:

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "CONFIG"         AND
                           craptab.cdacesso = "TXADIAPLIC"     AND
                           craptab.tpregist = tel_tpaplica
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF   NOT AVAILABLE craptab   THEN
             IF   LOCKED craptab   THEN
                  DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.

                      NEXT.
                  END.
             ELSE
                  DO:
                      glb_cdcritic = 55.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      PAUSE 5 NO-MESSAGE.
                      LEAVE.
                  END.

        RUN confirma.
          
        IF   aux_confirma <> "S"   THEN
             DO:

                FIND LAST w_taxas.
                
                /* apaga o registro que seria o novo, na temp-table */
                IF   AVAILABLE w_taxas   THEN
                     DELETE w_taxas.

                glb_cdcritic = 0.
                LEAVE.
             END.

        ASSIGN craptab.dstextab = aux_dstextab
               glb_cdcritic     = 0.
        
        RELEASE craptab.
        
        LEAVE.
    
    END.  /* fim DO .. TO.. */
    
    /* VERIFICA SE É POUPANCA PROGRAMADA */
    IF tel_tpaplica = 2 THEN
        DO:

            DO aux_contador = 1 TO 10:

                FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "CONFIG"         AND
                                   craptab.cdacesso = "TXADIAPLIC"     AND
                                   craptab.tpregist = 4
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                   
                IF   NOT AVAILABLE craptab   THEN
                     IF   LOCKED craptab   THEN
                          DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                					 INPUT "banco",
                                					 INPUT "craptab",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.

                              NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 55.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              PAUSE 5 NO-MESSAGE.
                              LEAVE.
                          END.
        
        
                ASSIGN craptab.dstextab = aux_dstextab
                       glb_cdcritic     = 0.
                
                RELEASE craptab.
                
                LEAVE.
    
            END.  /* fim DO .. TO.. */

        END.
    
    IF  glb_cdcritic <> 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            LEAVE.
        END.
                       
END PROCEDURE.

PROCEDURE opcao_e.
    
    IF   w_taxas.vlinifxa = 0   THEN
         DO:
            MESSAGE "Essa faixa/taxa nao pode ser excluida!".
            NEXT.
         END.
    
    DELETE w_taxas.
    
    RUN prepara_atualizacao.
            
    DO aux_contador = 1 TO 10:

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "CONFIG"         AND
                           craptab.cdacesso = "TXADIAPLIC"     AND
                           craptab.tpregist = tel_tpaplica
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF   NOT AVAILABLE craptab   THEN
             IF   LOCKED craptab   THEN
                  DO:
                      glb_cdcritic = 77.
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      glb_cdcritic = 55.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      PAUSE 5 NO-MESSAGE.
                      LEAVE.
                  END.

        RUN confirma.
          
        IF   aux_confirma <> "S"   THEN
             DO:
                glb_cdcritic = 0.
                LEAVE.
             END.

        ASSIGN craptab.dstextab = aux_dstextab
               glb_cdcritic     = 0.
        
        RELEASE craptab.
        
        LEAVE.
    
    END.  /* fim DO .. TO.. */
              
    IF  aux_confirma <> "S"   THEN
        RETURN.
              
    /* VERIFICA SE É POUPANCA PROGRAMADA */
    IF tel_tpaplica = 2 THEN
        DO:
            DO aux_contador = 1 TO 10:

                FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "CONFIG"         AND
                                   craptab.cdacesso = "TXADIAPLIC"     AND
                                   craptab.tpregist = 4
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                   
                IF   NOT AVAILABLE craptab   THEN
                     IF   LOCKED craptab   THEN
                          DO:
                              glb_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 55.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              PAUSE 5 NO-MESSAGE.
                              LEAVE.
                          END.
              
                ASSIGN craptab.dstextab = aux_dstextab
                       glb_cdcritic     = 0.
                
                RELEASE craptab.
                
                LEAVE.
            
            END.  /* fim DO .. TO.. */
        END.

        
    FOR EACH craptrd WHERE craptrd.cdcooper  = glb_cdcooper     AND
                           craptrd.dtiniper >= glb_dtmvtolt     AND
                           craptrd.tptaxrda  = tel_tpaplica     AND                      
                           craptrd.vlfaixas  = aux_vlinifxa
                           EXCLUSIVE-LOCK:
        DELETE craptrd.
    END.
                    
    IF  tel_tpaplica = 2 THEN
        DO:
            FOR EACH craptrd WHERE craptrd.cdcooper  = glb_cdcooper     AND
                                   craptrd.dtiniper >= glb_dtmvtolt     AND
                                   craptrd.tptaxrda  = 4                AND                      
                                   craptrd.vlfaixas  = aux_vlinifxa
                                   EXCLUSIVE-LOCK:
                DELETE craptrd.
            END.
        END.
          
    IF  glb_cdcritic <> 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            LEAVE.
        END.
    
END PROCEDURE.

PROCEDURE opcao_a.
    
    FORM SKIP(1)
         w_taxas.vlinifxa    AT  3  LABEL "De"
         w_taxas.vlfimfxa    AT 25  LABEL "Ate"
         w_taxas.vldataxa    AT 48  LABEL "Taxa"
                                    HELP "Informe o valor (%) da Taxa"
         SKIP(1)
         WITH ROW 10 CENTERED SIDE-LABELS OVERLAY WIDTH 68
              TITLE " Alteracao de Taxa " FRAME f_opcao_a.
        
    DISPLAY w_taxas.vlinifxa
            w_taxas.vlfimfxa        
            WITH FRAME f_opcao_a.
            
    UPDATE w_taxas.vldataxa WITH FRAME f_opcao_a.

    /* verifica se a porcentagem esta correta */

    FIND FIRST w_taxas2 WHERE w_taxas2.tpaplica = tel_tpaplica   AND
                              w_taxas2.vlinifxa > w_taxas.vlinifxa
                              NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE w_taxas2   THEN
         DO:
            IF   w_taxas.vldataxa >= w_taxas2.vldataxa   THEN
                 DO:
                    MESSAGE "Valor da taxa errado.".
                    NEXT.
                 END.
         END.
                                                   
    FIND LAST w_taxas2 WHERE w_taxas2.tpaplica = tel_tpaplica   AND
                             w_taxas2.vlinifxa < w_taxas.vlinifxa
                             NO-LOCK NO-ERROR.
                                       
    IF   AVAILABLE w_taxas2   THEN
         DO:
             IF   w_taxas.vldataxa <= w_taxas2.vldataxa   THEN
                  DO:
                      MESSAGE "Valor da taxa errado.".
                      NEXT.
                  END.
         END.

    RUN prepara_atualizacao.

    DO aux_contador = 1 TO 10:

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "CONFIG"         AND
                           craptab.cdacesso = "TXADIAPLIC"     AND
                           craptab.tpregist = tel_tpaplica
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF   NOT AVAILABLE craptab   THEN
             IF   LOCKED craptab   THEN
                  DO:
                      glb_cdcritic = 77.
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      glb_cdcritic = 55.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      PAUSE 5 NO-MESSAGE.
                      LEAVE.
                  END.

        RUN confirma.
          
        IF   aux_confirma <> "S"   THEN
             DO:
                glb_cdcritic = 0.
                LEAVE.
             END.

        ASSIGN craptab.dstextab = aux_dstextab
               glb_cdcritic     = 0.
        
        RELEASE craptab.
        
        LEAVE.
    
    END.  /* fim DO .. TO.. */
    
    /* ALTERACAO P/ TPREGIST = 4 */
    IF tel_tpaplica = 2 THEN
        DO:
            DO aux_contador = 1 TO 10:

                FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "CONFIG"         AND
                                   craptab.cdacesso = "TXADIAPLIC"     AND
                                   craptab.tpregist = 4
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                   
                IF   NOT AVAILABLE craptab   THEN
                     IF   LOCKED craptab   THEN
                          DO:
                              glb_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 55.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              PAUSE 5 NO-MESSAGE.
                              LEAVE.
                          END.
                
                ASSIGN craptab.dstextab = aux_dstextab
                       glb_cdcritic     = 0.
                
                RELEASE craptab.
                
                LEAVE.
            
            END.  /* fim DO .. TO.. */

        END.

    IF  glb_cdcritic <> 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            LEAVE.
        END.
    
END PROCEDURE.

PROCEDURE carrega_taxas.

    /* limpa a temp-table */
    EMPTY TEMP-TABLE w_taxas.    

    /* carrega todas as taxas */
    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "CONFIG"         AND
                           craptab.cdacesso = "TXADIAPLIC"     AND
                           craptab.tpregist <= 3 NO-LOCK:

        DO aux_qtdtaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
            
            CREATE w_taxas.
            ASSIGN aux_dsdfaixa = ENTRY(aux_qtdtaxas,craptab.dstextab,";")
                   w_taxas.tpaplica = craptab.tpregist
                   w_taxas.dsaplica = IF w_taxas.tpaplica = 1 THEN 
                                      "RDCA30"
                                   ELSE
                                   IF w_taxas.tpaplica = 2 THEN
                                      "POUP.PROGR."
                                   ELSE 
                                      "RDCA60"
                   w_taxas.vlinifxa = DECIMAL(ENTRY(1,aux_dsdfaixa,"#"))
                   w_taxas.vlfimfxa = 999999999.99
                   w_taxas.vldataxa = DECIMAL(ENTRY(2,aux_dsdfaixa,"#"))
                   w_taxas.taxadano = DECIMAL(ENTRY(3,aux_dsdfaixa,"#")).
                
        END.
    END.

    /* atribuir o valores finais de cada taxa */
    FOR EACH w_taxas.

        FIND FIRST w_taxas2 WHERE w_taxas2.dsaplica = w_taxas.dsaplica    AND
                                  w_taxas2.vlinifxa > w_taxas.vlinifxa    
                                  NO-LOCK NO-ERROR.
                       
        IF   AVAILABLE w_taxas2   THEN
             w_taxas.vlfimfxa = w_taxas2.vlinifxa - 0.01.
    END.

END PROCEDURE.

PROCEDURE prepara_atualizacao.

    /* monta as novas taxas para gravar na tabela */
    aux_dstextab = "".
    FOR EACH w_taxas WHERE w_taxas.tpaplica = tel_tpaplica NO-LOCK
                        BY w_taxas.vlinifxa:
    
        aux_dstextab = aux_dstextab + 
                       STRING(w_taxas.vlinifxa,"999999.99")   + "#" +
                       STRING(w_taxas.vldataxa,"999.999999")  + "#" + 
                       STRING(w_taxas.taxadano,"999.999999")  + ";".
    END.
    aux_dstextab = TRIM(aux_dstextab,";").
    
END PROCEDURE.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

PROCEDURE proc_acumula:

    TRANS_ACUMULA:
             
    DO TRANSACTION ON ENDKEY UNDO TRANS_ACUMULA, LEAVE TRANS_ACUMULA: 
                   
        /* PCAPTA */
        DO aux_contador = 1 TO 10:
                 
            ASSIGN glb_dscritic = "".
                     
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND    
                               craptab.nmsistem = "CRED"       AND    
                               craptab.cdempres = tel_tpaplica AND
                               craptab.tptabela = "GENERI"     AND    
                               craptab.cdacesso = "SOMAPLTAXA" AND    
                               craptab.tpregist = 0
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     IF   LOCKED craptab   THEN
                          DO:
                              glb_dscritic = 'Tabela "SOMAPLTAXA" esta sendo ' +
                                             'alterada. Tente novamente.'.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.               
                          END.
                     ELSE
                          DO:
                              CREATE craptab.
                              ASSIGN craptab.cdcooper = glb_cdcooper  
                                     craptab.nmsistem = "CRED"
                                     craptab.cdempres = tel_tpaplica
                                     craptab.tptabela = "GENERI"
                                     craptab.cdacesso = "SOMAPLTAXA" 
                                     craptab.tpregist = 0.
                              VALIDATE craptab.
                          END.            
                 END.
             
            LEAVE.
                     
        END. /* Fim do DO ... TO */
        
        IF   glb_dscritic <> ""   THEN
             DO:
                 BELL.
                 MESSAGE glb_dscritic.
                 UNDO TRANS_ACUMULA, LEAVE TRANS_ACUMULA.
             END.
             
        ASSIGN craptab.dstextab = IF   tel_flgpcapt    THEN 
                                       "SIM"
                                  ELSE 
                                       "NAO".

        /* RDCA30 */
        DO aux_contador = 1 TO 10:
                 
            ASSIGN glb_dscritic = "".
                     
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND    
                               craptab.nmsistem = "CRED"       AND    
                               craptab.cdempres = tel_tpaplica AND
                               craptab.tptabela = "GENERI"     AND    
                               craptab.cdacesso = "SOMAPLTAXA" AND    
                               craptab.tpregist = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     IF   LOCKED craptab   THEN
                          DO:
                              glb_dscritic = 'Tabela "SOMAPLTAXA" esta sendo ' +
                                             'alterada. Tente novamente.'.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.               
                          END.
                     ELSE
                          DO:
                              CREATE craptab.
                              ASSIGN craptab.cdcooper = glb_cdcooper  
                                     craptab.nmsistem = "CRED"
                                     craptab.cdempres = tel_tpaplica
                                     craptab.tptabela = "GENERI"
                                     craptab.cdacesso = "SOMAPLTAXA" 
                                     craptab.tpregist = 1.
                              VALIDATE craptab.
                          END.            
                 END.
             
            LEAVE.
                     
        END. /* Fim do DO ... TO */
                    
        IF   glb_dscritic <> ""   THEN
             DO:
                 BELL.
                 MESSAGE glb_dscritic.
                 UNDO TRANS_ACUMULA, LEAVE TRANS_ACUMULA.
             END.
             
        ASSIGN craptab.dstextab = IF   tel_flgrdc30    THEN 
                                       "SIM"
                                  ELSE 
                                       "NAO".
                                       
        /* POUPANCA PROGRAMADA */
        DO aux_contador = 1 TO 10:
                 
            ASSIGN glb_dscritic = "".
                     
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND    
                               craptab.nmsistem = "CRED"       AND    
                               craptab.cdempres = tel_tpaplica AND
                               craptab.tptabela = "GENERI"     AND    
                               craptab.cdacesso = "SOMAPLTAXA" AND    
                               craptab.tpregist = 2
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     IF   LOCKED craptab   THEN
                          DO:
                              glb_dscritic = 'Tabela "SOMAPLTAXA" esta sendo ' +
                                             'alterada. Tente novamente.'.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.               
                          END.
                     ELSE
                          DO:
                              CREATE craptab.
                              ASSIGN craptab.cdcooper = glb_cdcooper  
                                     craptab.nmsistem = "CRED"
                                     craptab.cdempres = tel_tpaplica
                                     craptab.tptabela = "GENERI"
                                     craptab.cdacesso = "SOMAPLTAXA" 
                                     craptab.tpregist = 2.
                              VALIDATE craptab.
                          END.            
                 END.
             
            LEAVE.
                     
        END. /* Fim do DO ... TO */
                    
        IF   glb_dscritic <> ""   THEN
             DO:
                 BELL.
                 MESSAGE glb_dscritic.
                 UNDO TRANS_ACUMULA, LEAVE TRANS_ACUMULA.
             END.
             
        ASSIGN craptab.dstextab = IF   tel_flgrdmpp   THEN 
                                       "SIM"
                                  ELSE 
                                       "NAO".
                                                                      
        /* RDCA60 */
        DO aux_contador = 1 TO 10:
                 
            ASSIGN glb_dscritic = "".
                     
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND    
                               craptab.nmsistem = "CRED"       AND    
                               craptab.cdempres = tel_tpaplica AND
                               craptab.tptabela = "GENERI"     AND    
                               craptab.cdacesso = "SOMAPLTAXA" AND    
                               craptab.tpregist = 3
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     IF   LOCKED craptab   THEN
                          DO:
                              glb_dscritic = 'Tabela "SOMAPLTAXA" esta sendo ' +
                                             'alterada. Tente novamente.'.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.               
                          END.
                     ELSE
                          DO:
                              CREATE craptab.
                              ASSIGN craptab.cdcooper = glb_cdcooper  
                                     craptab.nmsistem = "CRED"
                                     craptab.cdempres = tel_tpaplica
                                     craptab.tptabela = "GENERI"
                                     craptab.cdacesso = "SOMAPLTAXA" 
                                     craptab.tpregist = 3.
                              VALIDATE craptab.
                          END.            
                 END.
             
            LEAVE.
                     
        END. /* Fim do DO ... TO */
                    
        IF   glb_dscritic <> ""   THEN
             DO:
                 BELL.
                 MESSAGE glb_dscritic.
                 UNDO TRANS_ACUMULA, LEAVE TRANS_ACUMULA.
             END.
             
        ASSIGN craptab.dstextab = IF   tel_flgrdc60    THEN 
                                       "SIM"
                                  ELSE 
                                       "NAO".
                                                                               
        /* RDCPRE */
        DO aux_contador = 1 TO 10:
                 
            ASSIGN glb_dscritic = "".
                     
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND    
                               craptab.nmsistem = "CRED"       AND    
                               craptab.cdempres = tel_tpaplica AND
                               craptab.tptabela = "GENERI"     AND    
                               craptab.cdacesso = "SOMAPLTAXA" AND    
                               craptab.tpregist = 7
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     IF   LOCKED craptab   THEN
                          DO:
                              glb_dscritic = 'Tabela "SOMAPLTAXA" esta sendo ' +
                                             'alterada. Tente novamente.'.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.               
                          END.
                     ELSE
                          DO:
                              CREATE craptab.
                              ASSIGN craptab.cdcooper = glb_cdcooper  
                                     craptab.nmsistem = "CRED"
                                     craptab.cdempres = tel_tpaplica
                                     craptab.tptabela = "GENERI"
                                     craptab.cdacesso = "SOMAPLTAXA" 
                                     craptab.tpregist = 7.
                              VALIDATE craptab.
                          END.            
                 END.
             
            LEAVE.
                     
        END. /* Fim do DO ... TO */
                    
        IF   glb_dscritic <> ""   THEN
             DO:
                 BELL.
                 MESSAGE glb_dscritic.
                 UNDO TRANS_ACUMULA, LEAVE TRANS_ACUMULA.
             END.
             
        ASSIGN craptab.dstextab = IF   tel_flgrdpre    THEN 
                                       "SIM"
                                  ELSE 
                                       "NAO".
                                                                               
        /* RDCPOS */
        DO aux_contador = 1 TO 10:
                 
            ASSIGN glb_dscritic = "".
                     
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND    
                               craptab.nmsistem = "CRED"       AND    
                               craptab.cdempres = tel_tpaplica AND
                               craptab.tptabela = "GENERI"     AND    
                               craptab.cdacesso = "SOMAPLTAXA" AND    
                               craptab.tpregist = 8
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     IF   LOCKED craptab   THEN
                          DO:
                              glb_dscritic = 'Tabela "SOMAPLTAXA" esta sendo ' +
                                             'alterada. Tente novamente.'.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.               
                          END.
                     ELSE
                          DO:
                              CREATE craptab.
                              ASSIGN craptab.cdcooper = glb_cdcooper  
                                     craptab.nmsistem = "CRED"
                                     craptab.cdempres = tel_tpaplica
                                     craptab.tptabela = "GENERI"
                                     craptab.cdacesso = "SOMAPLTAXA" 
                                     craptab.tpregist = 8.
                              VALIDATE craptab.
                          END.            
                 END.
             
            LEAVE.
                     
        END. /* Fim do DO ... TO */
                    
        IF   glb_dscritic <> ""   THEN
             DO:
                 BELL.
                 MESSAGE glb_dscritic.
                 UNDO TRANS_ACUMULA, LEAVE TRANS_ACUMULA.
             END.
             
        ASSIGN craptab.dstextab = IF   tel_flgrdpos    THEN 
                                       "SIM"
                                  ELSE 
                                       "NAO".

        IF   log_flgrdc30 <> tel_flgrdc30   THEN
             UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                  " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                  "Operador " + glb_cdoperad +
                  " alterou o parametro de cumulatividade para RDCA30 de " +
                  STRING(log_flgrdc30,"SIM/NAO") + " para " +
                  STRING(tel_flgrdc30,"SIM/NAO") + " >> log/tab034.log").
            
        IF   log_flgrdmpp <> tel_flgrdmpp   THEN
             UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                  " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                  "Operador " + glb_cdoperad +
                  " alterou o parametro de cumulatividade para POUP.PROGRAMADA"
                  + " de " + STRING(log_flgrdmpp,"SIM/NAO") + " para " +
                  STRING(tel_flgrdmpp,"SIM/NAO") + " >> log/tab034.log").
                   
        IF   log_flgrdc60 <> tel_flgrdc60   THEN
             UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                  " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                  "Operador " + glb_cdoperad +
                  " alterou o parametro de cumulatividade para RDCA60 de " +
                  STRING(log_flgrdc60,"SIM/NAO") + " para " +
                  STRING(tel_flgrdc60,"SIM/NAO") + " >> log/tab034.log").
                             
        IF   log_flgrdpre <> tel_flgrdpre   THEN
             UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                  " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                  "Operador " + glb_cdoperad +
                  " alterou o parametro de cumulatividade para RDCPRE de " +
                  STRING(log_flgrdpre,"SIM/NAO") + " para " +
                  STRING(tel_flgrdpre,"SIM/NAO") + " >> log/tab034.log").
                                      
        IF   log_flgrdpos <> tel_flgrdpos   THEN
             UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                  " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                  "Operador " + glb_cdoperad +
                  " alterou o parametro de cumulatividade para RDCPOS de " +
                  STRING(log_flgrdpos,"SIM/NAO") + " para " +
                  STRING(tel_flgrdpos,"SIM/NAO") + " >> log/tab034.log"). 
             
        IF   log_flgpcapt <> tel_flgpcapt   THEN
             UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                  " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                  "Operador " + glb_cdoperad +
                  " alterou o parametro de cumulatividade para PCAPTA de " +
                  STRING(log_flgpcapt,"SIM/NAO") + " para " +
                  STRING(tel_flgpcapt,"SIM/NAO") + " >> log/tab034.log").
            
        
    END. /* Fim do DO TRANSACTION */

END PROCEDURE.

/* .......................................................................... */

