/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/iniprg.p                 | BTCH0002                          |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* .............................................................................

   Programa: Fontes/iniprg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Novembro/91                         Ultima atualizacao: 12/05/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado por outro programa.
   Objetivo  : Fazer os procedimentos de inicializacao dos programas batch.
               Deve ser enviado para esta rotina o campo glb_cdprogra.

   Alteracoes: 09/03/2000 - Tratar os programas em paralelo (Deborah).

               18/04/2002 - Incluir tratamento da limpeza batch (Margarete).
               
               31/01/2003 - Incluir acesso ao crapcop (Junior).

               07/10/2003 - Tratar limpeza com indicador 1 ou 2 (Deborah).

               11/03/2004 - Tirar critica 150. (Margarete).

               12/05/2004 - Atualizar glb_progerad (Margarete).

               20/05/2005 - Alimentar as variaveis:
                            glb_dtultdia (Ultimo dia do mes corrente)
                            glb_dtultdma (Ultimo dia do mes anterior) (Edson).
                            
               04/07/2005 - Alimentado campo cdcooper da tabela crapres (Diego).

               15/08/2005 - Capturar codigo da cooperativa da variavel de 
                            ambiente CDCOOPER (Edson).
               
               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               18/06/2005 - Capturar o codigo da cooperativa da variavel de 
                            ambiente CDCOOPER (Edson).

               02/08/2007 - Capturar o nome do pacote da variavel de ambiente
                            PKGNAME (Edson).
                            
                          - Monitorar leituras por programas (Fernando).
                          
               07/02/2012 - Utilizar variavel glb_flgresta para criar a
                            tabela de restart (David).
                            
               25/01/2013 - Projeto Oracle - Inclusão chamada Store-Procedure
                           (Guilherme).
                           
               07/08/2013 - Incluso VALIDATE crapres para "commitar" o registro
                            no Oracle (Guilherme).
                            
               12/05/2014 - Variaveis Projeto Oracle + gravar modulo com prg
                            que esta executando no momento (Guilherme).

............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

DEF        STREAM str_1.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgatend AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrusuari AS CHARACTER                             NO-UNDO.
DEF        VAR aux_nmmodora AS CHARACTER                             NO-UNDO.

/*  Captura o nome do pacote da variavel de ambiente PKGNAME ................ */

glb_nmpacote = OS-GETENV("PKGNAME").

IF   glb_nmpacote = ?   THEN
     ASSIGN glb_nmpacote = ""
            glb_dsdirpkg = "".
ELSE
     glb_dsdirpkg = "/" + glb_nmpacote.
     
/*  Captura codigo da cooperativa da variavel de ambiente CDCOOPER .......... */

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   glb_cdcooper = ?   THEN
     glb_cdcooper = 0.
                         
/* .......................................................................... */


/* ...........Indicacao ao ORACLE que o programa esta sendo executado........ */

DO TRANSACTION:

    /********* nao funciona sem dataserver
    DEFINE VAR h-stored-oracle AS INTEGER.
    
    RUN STORED-PROC send-sql-statement h-stored-oracle = PROC-HANDLE
            ("SELECT habilita_modulo_trace('" + glb_cdprogra + "') from dual").
    FOR EACH proc-text-buffer WHERE PROC-HANDLE = h-stored-oracle.
    END.
    CLOSE STORED-PROC send-sql-statement WHERE PROC-HANDLE = h-stored-oracle.
    ***********************/
END.

/* .......................................................................... */


DO WHILE TRUE:

   ASSIGN glb_cdcritic = 0
          glb_inrestar = 1
          glb_infimsol = FALSE.

   /*  Verifica se a cooperativa esta cadastrada ............................ */
   
   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop   THEN
        DO:
            glb_cdcritic = 651.
            RUN fontes/critic.p.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + " >> log/proc_batch.log").
            LEAVE.
        END.
   
   glb_nmrescop = crapcop.nmrescop.

   /*  Captura o nome do servidor da variavel de ambiente HOST .............. */

   glb_hostname = OS-GETENV("HOST").

   IF   glb_hostname = ?   OR
        glb_hostname = ""  THEN
        DO:
            glb_cdcritic = 999.
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                              glb_cdprogra + "' --> '"  + 
                              "ERRO: Variavel glb_hostname NAO inicializada." + 
                              " >> log/proc_batch.log").
            LEAVE.
        END.

   /*  Le data do sistema ................................................... */
   
   FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapdat   THEN
        DO:
            glb_cdcritic = 1.
            RUN fontes/critic.p.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + " >> log/proc_batch.log").
            LEAVE.
        END.

   ASSIGN glb_dtmvtolt = crapdat.dtmvtolt
          glb_dtmvtopr = crapdat.dtmvtopr
          glb_dtmvtoan = crapdat.dtmvtoan
          glb_inproces = crapdat.inproces
          glb_qtdiaute = crapdat.qtdiaute
   
          glb_dtultdma = crapdat.dtmvtolt - DAY(crapdat.dtmvtolt)
       
          glb_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) +
                                      4) - DAY(DATE(MONTH(glb_dtmvtolt),28,
                                                    YEAR(glb_dtmvtolt)) + 4)).
  
   IF   glb_flgbatch   THEN
        DO:
            IF   crapdat.inproces < 3 THEN
                 DO:
                     IF   crapdat.inproces = 1 OR 
                          crapdat.inproces = 2 THEN /* Limpeza batch */
                          DO:
                              FIND crapprg WHERE 
                                   crapprg.cdcooper = glb_cdcooper  AND
                                   crapprg.cdprogra = glb_cdprogra
                                   NO-LOCK NO-ERROR.

                              IF   NOT AVAILABLE crapprg THEN
                                   glb_cdcritic = 145.
                              ELSE
                              DO:
                                  FIND crapord WHERE  
                                       crapord.cdcooper = glb_cdcooper     AND
                                       crapord.nrsolici = crapprg.nrsolici 
                                       NO-LOCK NO-ERROR.
                                       
                                  IF   NOT AVAILABLE crapord THEN
                                       glb_cdcritic = 664.
                                  ELSE                     
                                       IF   crapord.tpcadeia <> 2   THEN     
                                            glb_cdcritic = 141.
                          
                              END.
                          END.
                     ELSE                
                          glb_cdcritic = 141.
                          
                     IF   glb_cdcritic <> 0   THEN
                          DO:
                              RUN fontes/critic.p.
                              UNIX SILENT VALUE
                                   ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" +
                                    glb_dscritic + " >> log/proc_batch.log").
                              LEAVE.
                          END.
                 END.

            IF   crapdat.cdprgant <> " " THEN
                 DO:
                     FIND crapprg WHERE crapprg.cdcooper = glb_cdcooper     AND
                                        crapprg.cdprogra = crapdat.cdprgant
                                        NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE crapprg THEN
                          DO:
                              glb_cdcritic = 143.
                              RUN fontes/critic.p.
                              UNIX SILENT VALUE
                                   ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" +
                                    glb_dscritic + " >> log/proc_batch.log").
                              LEAVE.
                          END.
                     ELSE
                          IF   crapprg.inctrprg <> 2 THEN
                               DO:
                                   glb_cdcritic = 144.
                                   RUN fontes/critic.p.
                                   UNIX SILENT VALUE
                                        ("echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> log/proc_batch.log").
                                   LEAVE.
                               END.
                 END.
        END.

   /*  Verifica se o programa esta cadastrado ............................... */
   
   FIND crapprg WHERE crapprg.cdcooper = glb_cdcooper AND
                      crapprg.cdprogra = glb_cdprogra NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapprg THEN
        DO:
            glb_cdcritic = 145.
            RUN fontes/critic.p.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + " >> log/proc_batch.log").
            LEAVE.
        END.
   ELSE
        IF   crapprg.inctrprg <> 1 THEN
             IF   glb_flgbatch   THEN
                  DO:
                      glb_cdcritic = 146.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> log/proc_batch.log").
                      LEAVE.
                  END.

   ASSIGN glb_cdrelato[1] = crapprg.cdrelato[1]
          glb_cdrelato[2] = crapprg.cdrelato[2]
          glb_cdrelato[3] = crapprg.cdrelato[3]
          glb_cdrelato[4] = crapprg.cdrelato[4]
          glb_cdrelato[5] = crapprg.cdrelato[5]
          glb_nmdestin    = "".

          aux_regexist = FALSE.

   IF   crapprg.nrsolici = 50   THEN /* TELAS */
        ASSIGN glb_progerad = "TEL".
   ELSE
        ASSIGN glb_progerad = 
                   STRING(SUBSTRING(STRING(glb_cdprogra,"x(07)"),5,3)).

   FIND craprel WHERE craprel.cdcooper = glb_cdcooper    AND
                      craprel.cdrelato = glb_cdrelato[1] NO-LOCK NO-ERROR. 
   
   ASSIGN glb_nmdestin[1] = IF AVAILABLE craprel 
                               THEN "DESTINO: " + CAPS(craprel.nmdestin)
                               ELSE "".
   
   FIND craprel WHERE craprel.cdcooper = glb_cdcooper AND
                      craprel.cdrelato = glb_cdrelato[2] NO-LOCK NO-ERROR. 
 
   ASSIGN glb_nmdestin[2] = IF AVAILABLE craprel 
                               THEN "DESTINO: " + CAPS(craprel.nmdestin)
                               ELSE "".
   
   FIND craprel WHERE craprel.cdcooper = glb_cdcooper    AND
                      craprel.cdrelato = glb_cdrelato[3] NO-LOCK NO-ERROR. 
                      
   ASSIGN glb_nmdestin[3] = IF AVAILABLE craprel 
                               THEN "DESTINO: " + CAPS(craprel.nmdestin)
                               ELSE "".

   FIND craprel WHERE craprel.cdcooper = glb_cdcooper    AND
                      craprel.cdrelato = glb_cdrelato[4] NO-LOCK NO-ERROR. 
                  
   ASSIGN glb_nmdestin[4] = IF AVAILABLE craprel 
                               THEN "DESTINO: " + CAPS(craprel.nmdestin)
                               ELSE "".

   FIND craprel WHERE craprel.cdcooper = glb_cdcooper    AND
                      craprel.cdrelato = glb_cdrelato[5] NO-LOCK NO-ERROR. 
                      
   ASSIGN glb_nmdestin[5] = IF AVAILABLE craprel 
                               THEN "DESTINO: " + CAPS(craprel.nmdestin)
                               ELSE "".
                           
   FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper     AND
                          crapsol.nrsolici = crapprg.nrsolici NO-LOCK:

       IF   crapsol.insitsol = 1   THEN
            DO:
                ASSIGN glb_cdempres = crapsol.cdempres
                       glb_nrdevias = crapsol.nrdevias
                       glb_dsparame = crapsol.dsparame
                       glb_nrseqsol = crapsol.nrseqsol
                       aux_regexist = TRUE
                       aux_flgatend = FALSE.
                LEAVE.
            END.
       ELSE
            DO:
                ASSIGN aux_flgatend = TRUE
                       aux_regexist = TRUE.
                NEXT.
            END.

   END.  /*  Fim do FOR EACH  */

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 149.
            RUN fontes/critic.p.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + " >> log/proc_batch.log").
            LEAVE.
        END.
   ELSE
        IF   aux_flgatend   THEN
             DO:
                 FIND crapord WHERE crapord.cdcooper = glb_cdcooper     AND
                                    crapord.nrsolici = crapprg.nrsolici 
                                    NO-LOCK NO-ERROR.
                 
                 IF   NOT AVAILABLE crapord THEN
                      DO: 
                          glb_cdcritic = 664.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE ("echo " + 
                               STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").
                          LEAVE.
                      END.
             END.
             
   IF   glb_flgresta   THEN
        DO:
            FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                               crapres.cdprogra = glb_cdprogra NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapres THEN
            DO:
                 DO TRANSACTION:
         
                    CREATE crapres.
                    ASSIGN crapres.cdprogra = glb_cdprogra
                           crapres.nrdconta = 0
                           glb_nrctares     = 0
                           glb_inrestar     = 0
                           glb_dsrestar     = ""
                           crapres.cdcooper = glb_cdcooper.
                 
                 END.  /*  Fim da transacao  */

                 VALIDATE crapres.
            END.
            ELSE
                 DO:
                     ASSIGN glb_nrctares = crapres.nrdconta
                            glb_dsrestar = crapres.dsrestar
                            glb_inrestar = 1
                            glb_cdcritic = 152.
         
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + 
                                        " - " + glb_cdprogra + "' --> '" + 
                                        glb_dscritic + " " +
                                        STRING(crapres.nrdconta,"zzzz,zzz,9") +
                                        " >> log/proc_batch.log").
                     glb_cdcritic = 0.
                 END.
        END.
   
   /* Pegar PID da conexão 
   INPUT STREAM str_1 THROUGH VALUE( "MyPid.sh 2> /dev/null")
                NO-ECHO.
                   
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_1 UNFORMATTED aux_nrusuari.
         
   END.  /*  Fim do DO WHILE TRUE  */

   FIND FIRST _connect WHERE
              _connect._connect-pid = INTE(aux_nrusuari) NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE _connect   THEN
        DO:                   
           LEAVE.
        END.
   ELSE 
        ASSIGN aux_nrusuari = STRING(_connect._connect-usr).

   FOR EACH _usertablestat NO-LOCK:

       IF   (_usertablestat._usertablestat-create  <> 0 OR
             _usertablestat._usertablestat-delete  <> 0 OR
             _usertablestat._userTablestat-update  <> 0 OR
             _usertablestat._usertablestat-read    <> 0   ) AND
             _usertablestat._usertablestat-conn = INTE(aux_nrusuari)  THEN
            DO:
               FIND _file WHERE
                    _file._file-number = _usertablestat._usertablestat-num
                    NO-LOCK NO-ERROR.

               CREATE tb_statusPrograma.
               ASSIGN tb_statusPrograma.DataColeta = TODAY
                      tb_statusPrograma.NmPrograma = glb_cdprogra
                      tb_statusPrograma.NmTabela   = _file._file-name
                      tb_statusPrograma.NrTabela   = _file._file-number
                      tb_statusPrograma.NrConexao  = INTE(aux_nrusuari)
                      tb_statusPrograma.TotCreates = _usertablestat._usertablestat-create
                      tb_statusPrograma.TotDeletes = _usertablestat._usertablestat-delete
                      tb_statusPrograma.TotReads   = _usertablestat._usertablestat-read
                      tb_statusPrograma.TotUpdates = _usertablestat._usertablestat-update.
            END.
   END.   Fim do FOR EACH  */

   { includes/PLSQL_grava_operacao_modulo.i &dboraayl={&scd_dboraayl} }
                           
   LEAVE.

END.

/* .......................................................................... */

