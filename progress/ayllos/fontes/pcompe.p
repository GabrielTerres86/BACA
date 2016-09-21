/* .............................................................................

    Programa: fontes/pcompe.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Abril/2007                      Ultima atualizacao: 18/12/2012

    Dados referentes ao programa:

    Frequencia: Diario (On-Line).
    Objetivo  : Mostrar Tela PCOMPE. 
                Envia arquivos de compensacao a Intranet BANCOOB.

    Alteracoes: 01/10/2007 - Alterada mensagem de liberacao de operador
                             bloqueado (Evandro).
                           - Enviar arquivos de Cliente SFN (David).
                           
                21/11/2007 - Incluidos arquivos do INSS-BANCOOB (Evandro).
                
                15/02/2008 - Utilizar tpregist = 99 para o controle de uso da
                             tela (Evandro).
                             
                31/03/2008 - Considerar os arquivos GPS-BANCOOB (Evandro).
                
                09/05/2008 - Incluidos arquivos CONTINUO-BANCOOB (Elton).
                
                04/06/2008 - Melhorado o log e passagem do nome do usuario ao
                             script upload.sh (Evandro).
                             
                20/05/2009 - Alteracao CDOPERAD (Kbase).
                
                18/09/2009 - Alterado para logar somente senhas incorretas
                             (Diego).
                             
                28/10/2010 - Alterado para validar senha atraves do fonte
                             pedesenha.p (Adriano).
                             
                25/04/2011 - Retirada opcao de envio de arquivos relativos a
                             Previdencia (INSS) - Arquivos do tipo 
                             "INSS-BANCOOB" (GATI - Eder)
                             
                03/04/2012 - Incluido controle de log ao enviar arquivos 
                             conforme usado na tela prprev (Adriano).
                
                18/12/2012 - Retirar o envio dos arquivos de devolucao. Postar
                             manualmente na intranet Bancoob (Ze).
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_ultlinha AS INTE                                           NO-UNDO.
DEF VAR aux_nrbarras AS INTE                                           NO-UNDO.

DEF VAR aux_flgsenha AS LOGI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR aux_tparquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dsarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdsenha AS CHAR                                           NO-UNDO.
DEF VAR aux_arqlista AS CHAR                                           NO-UNDO.
DEF VAR aux_prprevlog AS CHAR                                          NO-UNDO.
DEF VAR aux_arqderro  AS CHAR                                          NO-UNDO.

DEF VAR aux_setlinha AS CHAR    FORMAT "x(150)"                        NO-UNDO.

DEF TEMP-TABLE crawarq                                                 NO-UNDO
    FIELD tparquiv AS CHAR
    FIELD nmarquiv AS CHAR.
    
DEF TEMP-TABLE w-arquivos                                              NO-UNDO
    FIELD tparquiv AS CHAR  
    FIELD dsarquiv AS CHAR.

DEF QUERY q_w-arquivos FOR w-arquivos.

DEF BROWSE b_w-arquivos QUERY q_w-arquivos
    DISPLAY w-arquivos.tparquiv COLUMN-LABEL "TIPO"      FORMAT "x(16)"
            w-arquivos.dsarquiv COLUMN-LABEL "DESCRICAO" FORMAT "x(50)"
    WITH 7 DOWN WIDTH 74 TITLE "Arquivos a serem enviados".
    
FORM 
    WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela
    ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_moldura.
    
FORM SKIP(1)
    glb_cddopcao AT  5 LABEL  "Opcao"
                       HELP "Informe a opcao(E - Envio arq. BANCOOB)"
                       VALIDATE(CAN-DO("E",glb_cddopcao),
                                       "014 - Opcao errada.")
    SKIP(1)
    b_w-arquivos AT  3 HELP "Pressione DELETE para excluir / F4 para sair"
    SKIP(2)
    WITH ROW 4 OVERLAY SIDE-LABELS NO-LABELS WIDTH 80 TITLE glb_tldatela 
    FRAME f_pcompe.
          
FORM 
    SKIP(1)
    aux_dsdsenha AT  3 LABEL "Senha" FORMAT "x(15)" BLANK 
                       HELP "Informe a senha da Intranet BANCOOB"
                       VALIDATE(aux_dsdsenha <> "",
                                "003 - Senha errada.")  
    SKIP(1)
    WITH ROW 11 WIDTH 28 CENTERED OVERLAY TITLE "Senha Intranet BANCOOB"
         SIDE-LABEL FRAME f_senha_bancoob.


ON "DELETE" OF b_w-arquivos IN FRAME f_pcompe 
    DO:
        IF  NOT AVAILABLE w-arquivos  THEN
            RETURN.
             
        DELETE w-arquivos. 
        
        ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_w-arquivos").
    
        OPEN QUERY q_w-arquivos FOR EACH w-arquivos BY w-arquivos.tparquiv.
    
        REPOSITION q_w-arquivos TO ROW aux_ultlinha.
    END.
    
RUN fontes/inicia.p.

ASSIGN glb_cdcritic = 0
       glb_cddopcao = "E".

DO WHILE TRUE:
   
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND 
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "NRARQMVBCB" AND
                       craptab.tpregist = 99           NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE craptab  THEN
        DO:
            DO TRANSACTION:
            
                CREATE craptab.
                ASSIGN craptab.cdcooper = glb_cdcooper
                       craptab.nmsistem = "CRED"   
                       craptab.tptabela = "GENERI"
                       craptab.cdempres = 0
                       craptab.cdacesso = "NRARQMVBCB"
                       craptab.tpregist = 99.
                   
            END.
            
            RELEASE craptab.
            
            LEAVE.       
        END.
    
    IF  craptab.dstextab <> ""  THEN
        DO:
            HIDE MESSAGE.

            MESSAGE "Esta tela esta sendo usada pelo operador"
                    craptab.dstextab.
        
            IF  glb_cdoperad <> SUBSTRING(craptab.dstextab,1,10)  THEN
                DO:
                    MESSAGE "Peca a liberacao ao Coordenador/Gerente...".
                    PAUSE 2 NO-MESSAGE.

                    RUN fontes/pedesenha.p (INPUT  glb_cdcooper,
                                            INPUT  1,
                                            OUTPUT aux_flgsenha,
                                            OUTPUT aux_cdoperad).
                                          
                    IF  aux_flgsenha  THEN
                        LEAVE.
                END.
            ELSE
                DO:
                    MESSAGE "Aguarde ou pressione F4/END para sair...".
                    READKEY PAUSE 2.
                END.
                 
            IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    ASSIGN glb_nmdatela = "".
                    RETURN.
                END.

            NEXT.
        END.   
    ELSE
        DO TRANSACTION:
            
            FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR.
            
            IF  AVAILABLE craptab  THEN
                craptab.dstextab = STRING(glb_cdoperad,"x(10)") + "-" +
                                   glb_nmoperad.
                 
            RELEASE craptab.
        
            HIDE MESSAGE.
        
        END. 

    LEAVE.
   
END. /*** Fim do DO WHILE ***/        
    
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

VIEW FRAME f_moldura.

PAUSE(0).

DO WHILE TRUE:
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE glb_cddopcao WITH FRAME f_pcompe.
        LEAVE.
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "PCOMPE"  THEN
                DO:
                    DO TRANSACTION:
                    
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                           craptab.nmsistem = "CRED"       AND
                                           craptab.tptabela = "GENERI"     AND
                                           craptab.cdempres = 00           AND
                                           craptab.cdacesso = "NRARQMVBCB" AND
                                           craptab.tpregist = 99
                                           EXCLUSIVE-LOCK NO-ERROR.
            
                        IF  AVAILABLE craptab  THEN
                            ASSIGN craptab.dstextab = "".
                    
                    END. /*** Fim do DO TRANSACTION ***/
                    
                    HIDE FRAME f_moldura  NO-PAUSE.
                    HIDE FRAME f_pcompe   NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = INPUT glb_cddopcao.
        END.
           
    IF  glb_cddopcao = "E"  THEN
        DO:
            RUN carrega_tabela_envio.

            OPEN QUERY q_w-arquivos FOR EACH w-arquivos NO-LOCK.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_w-arquivos WITH FRAME f_pcompe.
                LEAVE.
            END.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = "N"
                       glb_cdcritic = 78.
                RUN fontes/critic.p.
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                LEAVE.
            END.
                             
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                aux_confirma <> "S"                 THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    ASSIGN glb_cdcritic = 0.
                    CLOSE QUERY q_w-arquivos. 
                    NEXT.
                END.

            CLOSE QUERY q_w-arquivos.

            ASSIGN aux_arqlista = "".
            
            FOR EACH w-arquivos NO-LOCK,
                EACH crawarq WHERE crawarq.tparquiv = w-arquivos.tparquiv 
                                   NO-LOCK:            
                 
                ASSIGN aux_nrbarras = NUM-ENTRIES(crawarq.nmarquiv,"/")
                       aux_nmarquiv = ENTRY(aux_nrbarras,crawarq.nmarquiv,"/")
                       aux_arqlista = aux_arqlista + aux_nmarquiv + ",".

            END.
                     
            IF  aux_arqlista = ""  THEN
                DO:
                    ASSIGN glb_cdcritic = 239.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    ASSIGN glb_cdcritic = 0.
                END.
            ELSE
                DO:
                    ASSIGN aux_dsdsenha = "".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE aux_dsdsenha WITH FRAME f_senha_bancoob.
                        LEAVE.
                    END.
                    
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO:
                            ASSIGN glb_cdcritic = 79.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            ASSIGN glb_cdcritic = 0.
                            NEXT.
                        END.
                        
                    HIDE FRAME f_senha_bancoob.
                        
                    ASSIGN aux_arqlista = SUBSTR(aux_arqlista,1,
                                                 LENGTH(aux_arqlista) - 1)
                           aux_prprevlog = "/usr/coop/cecred/log/prprev.log"
                           aux_arqderro  = "/usr/coop/cecred/log/msgerro.log".

                     IF SEARCH(aux_prprevlog) = ? THEN
                        UNIX SILENT VALUE(" > " + aux_prprevlog).
                     
                     IF SEARCH(aux_arqderro) = ? THEN
                        UNIX SILENT VALUE(" > " + aux_arqderro).
                                                 
                    /* pega o nome do usuario no UNIX para o upload.sh */
                    INPUT STREAM str_1 THROUGH VALUE("who am i").
                    IMPORT STREAM str_1 aux_setlinha.
                    INPUT STREAM str_1 CLOSE.
                    
                    UNIX SILENT VALUE("echo " +
                                      STRING(glb_dtmvtolt,"99/99/9999") +
                                      " - " + STRING(TIME,"HH:MM:SS") +
                                      " - OPERADOR: " +
                                      glb_cdoperad +
                                      "' --> '" + STRING(crapcop.cdagebcb) +
                                      " " + aux_arqlista + 
                                      ">> log/proc_batch.log").
                        
                    UNIX SILENT VALUE(" sudo upload.sh " +
                                STRING(crapcop.cdagebcb) +
                                " " +
                                aux_dsdsenha + 
                                " " +
                                aux_arqlista +
                                " " +
                                aux_setlinha + "").
                                     
                    IF SEARCH(aux_arqderro) <> ? THEN
                       UNIX SILENT VALUE("rm " + aux_arqderro + 
                                         " 2> /dev/null").

                    RUN verifica_log.
                    
                END.
 
        END.

END. /*** Fim do DO WHILE ***/
    
PROCEDURE carrega_tabela_envio.

    EMPTY TEMP-TABLE crawarq.
    EMPTY TEMP-TABLE w-arquivos.
   
    /*** Procura arquivos CCF ***/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/bancoob/BCB_CCF*"
           aux_tparquiv = "CCF". 
    
    RUN verifica_arquivos.         
    
    /*** Procura arquivos CONTRA-ORDEM ***/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/bancoob/BCB_CONTRAO*"
           aux_tparquiv = "CONTRA-ORDEM". 
            
    RUN verifica_arquivos.
     
    /*** Procura arquivos TITULOS ***/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/bancoob/ti*.CBE"
           aux_tparquiv = "TITULOS". 
            
    RUN verifica_arquivos.
     
    /*** Procura arquivos COMPEL ***/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/bancoob/ch*.CBE"
           aux_tparquiv = "COMPEL". 
            
    RUN verifica_arquivos.
     
    /*** Procura arquivos DOCTOS ***/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/bancoob/dc*.CBE"
           aux_tparquiv = "DOCTOS". 
            
    RUN verifica_arquivos.

    /*** Procura arquivos Cliente SFN ***/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop +
                          "/bancoob/ICF605_*.txt"
           aux_tparquiv = "SFN".
                          
    RUN verifica_arquivos.                      

    /*   ******************************* 
    O envio sera efetuado pela PRPREV    
    
    *** Procura arquivos INSS-BANCOOB ***
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop +
                          "/bancoob/0" + STRING(crapcop.cdagebcb,"9999") +
                          "*.RET*"
           aux_tparquiv = "INSS-BANCOOB".
                          
    RUN verifica_arquivos.                      
    
    ********************************   */
    
    /*** Procura arquivos GPS-BANCOOB ***/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop +
                          "/bancoob/" + STRING(crapcop.cdagebcb,"9999") +
                          "*.gps"
                          
           aux_tparquiv = "GPS-BANCOOB".
                          
    RUN verifica_arquivos.                      

    /*** Procura arquivos CONTINUO-BANCOOB ***/
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/bancoob/pd*BANCOOB"
           aux_tparquiv = "CONTINUO-BANCOOB". 
    
    RUN verifica_arquivos.
    
    ASSIGN aux_tparquiv = "".

    FOR EACH crawarq NO-LOCK BREAK BY crawarq.tparquiv:
    
        IF  FIRST-OF(crawarq.tparquiv)  THEN
            DO:
                IF  crawarq.tparquiv = "CCF"  THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO INCLUSAO/EXCLUSAO CCF".
                ELSE
                IF  crawarq.tparquiv = "CONTRA-ORDEM"  THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO INCLUSAO/EXCLUSAO " +
                                          "CONTRA-ORDEM".
                ELSE
                IF  crawarq.tparquiv = "TITULOS"  THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO TITULOS COMPENSAVEIS".
                ELSE
                IF  crawarq.tparquiv = "COMPEL"  THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO COMPENSACAO ELETRONICA".
                ELSE
                IF  crawarq.tparquiv = "DOCTOS"  THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO DOCTOS".
                ELSE
                IF  crawarq.tparquiv = "SFN"  THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO CLIENTE SFN".
                
                /*** O envio ao bancoob sera feito pela PRPREV *** 
                
                ELSE
                IF  crawarq.tparquiv = "INSS-BANCOOB"  THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO INSS BANCOOB".
                *** fim do envio dos arquivos de beneficios *** */
                
                ELSE
                IF  crawarq.tparquiv = "GPS-BANCOOB"  THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO GPS BANCOOB".
                ELSE            
                IF  crawarq.tparquiv = "CONTINUO-BANCOOB" THEN
                    ASSIGN aux_tparquiv = crawarq.tparquiv
                           aux_dsarquiv = "ARQUIVO FORMULARIOS CONTINUOS " +
                                          "BANCOOB". 
                           
                CREATE w-arquivos.
                ASSIGN w-arquivos.tparquiv = aux_tparquiv
                       w-arquivos.dsarquiv = aux_dsarquiv.
            END.
    
    END.

END PROCEDURE.

PROCEDURE verifica_arquivos:

    INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null")
          NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        SET STREAM str_1 aux_nmarquiv FORMAT "x(60)".
        
        /*** Verifica se o arquivo esta vazio e o remove ***/
        INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_nmarquiv + 
                                         " 2> /dev/null") NO-ECHO.
                                                  
        SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
             
        IF  INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0  THEN
            DO:
                INPUT STREAM str_2 CLOSE.
                NEXT.
            END.

        INPUT STREAM str_2 CLOSE.
                
        DO TRANSACTION:         
            CREATE crawarq.
            ASSIGN crawarq.tparquiv = aux_tparquiv
                   crawarq.nmarquiv = aux_nmarquiv.
        END.
                
    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.
    
END PROCEDURE.
                

PROCEDURE verifica_log.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/log/pcompe.log".
                   
    IF SEARCH(aux_nmarquiv) <>  ? THEN
       DO:                       
          INPUT STREAM str_1 
                THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.
            
          SET STREAM str_1 aux_nmarquiv FORMAT "x(60)".
                         
          INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.   

          IMPORT STREAM str_1 UNFORMATTED aux_setlinha.          
               
          MESSAGE aux_setlinha VIEW-AS ALERT-BOX .
                  
          UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                                      " - " + STRING(TIME,"HH:MM:SS") +
                                      " - OPERADOR: " +
                                      glb_cdoperad + " - TELA: PCOMPE" +
                                      "' --> '" + "Senha incorreta: " +
                                      aux_dsdsenha + " Usuario: " + 
                                      aux_setlinha + " >> log/proc_batch.log").

          INPUT STREAM str_1 CLOSE.
    
       END.   
    
END PROCEDURE.


/* .......................................................................... */
