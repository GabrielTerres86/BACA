/* ...........................................................................

Alteracoes: 16/09/2010 - Substituido aux_nmrescop[crapcop.cdcooper]  por
                         aux_dsdircop[crapcop.cdcooper] na remocao e gravacao 
                         dos arquivos (Elton).

            24/11/2010 - Incluido Sistema TAA (Evandro).

            05/04/2011 - Ajustada a identacao no fonte e inserida opcao
                         para cadastro de programas nao compilaveis (Fernando).
                         
            26/09/2011 - Informar WARNINGS no log de erros (Evandro).

            25/10/2011 - Nao copiar fontes para pasta sistema e siscaixa
                         das cooperativas - unificacao de diretorios
                         (Fernando).

            27/02/2013 - Nao eliminar o .r mesmo em caso de erros de compilacao,
                         criada procedure valida_compilacao para compilar
                         temporariamente antes da compilacao final (Evandro).

            03/07/2013 - Gerar .off para o CQL.w (Evandro).
............................................................................*/

/* includes para gerar o .w de um html */
{ src/web/method/cgidefs.i "NEW"}

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.
                                                              
DEF VAR aux_cddopcao  AS INTE                                         NO-UNDO.
DEF VAR aux_tpcompil  AS LOGICAL FORMAT "Todos/Escolher"              NO-UNDO.
DEF VAR aux_confirma  AS LOGICAL FORMAT "S/N"                         NO-UNDO.
DEF VAR aux_cdprogra  AS CHAR                                         NO-UNDO.
DEF VAR aux_dsarquiv  AS CHAR                                         NO-UNDO.
DEF VAR aux_ultlinha  AS INTE                                         NO-UNDO.
DEF VAR aux_dtmvtolt  AS DATE                                         NO-UNDO.
DEF VAR aux_nmprimtl  AS CHAR                                         NO-UNDO.
DEF VAR aux_dsncompi1 AS CHAR                                         NO-UNDO.
DEF VAR aux_dsncompi2 AS CHAR                                         NO-UNDO.
                                                        
DEF VAR aux_caminho  AS CHAR                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                          NO-UNDO.
DEF VAR aux_dsdlinha AS CHAR                                          NO-UNDO.
DEF VAR aux_propath  AS CHAR                                          NO-UNDO.
DEF VAR aux_dsdbusca AS CHAR                                          NO-UNDO.

DEF VAR aux_flgerros AS LOGICAL                                       NO-UNDO.
DEF VAR aux_qtderros AS INTE                                          NO-UNDO.

DEF VAR aux_nmrescop AS CHAR            EXTENT 99                     NO-UNDO.
DEF VAR aux_dsdircop AS CHAR            EXTENT 99                     NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                          NO-UNDO.

DEF TEMP-TABLE arquivos
    FIELD dsdireto   AS CHAR
    FIELD nmarquiv   AS CHAR    FORMAT "x(25)"
    FIELD selected   AS LOGICAL FORMAT "Sim/Nao"
    INDEX arquivos1  AS PRIMARY UNIQUE nmarquiv dsdireto.

DEF BUFFER b_arquivos FOR arquivos.    

DEF QUERY  q_escolhe FOR arquivos.
DEF BROWSE b_escolhe QUERY q_escolhe
           DISPLAY arquivos.nmarquiv  COLUMN-LABEL "Arquivo"
                   arquivos.selected  COLUMN-LABEL "Compilar"
                   WITH 14 DOWN.

DEF TEMP-TABLE tt_naocompilaveis   NO-UNDO
    FIELD cdprogra AS CHAR
    FIELD dsmotivo AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD nmprimtl AS CHAR
    INDEX tt_naocompilaveis1 AS PRIMARY UNIQUE cdprogra.

DEF QUERY q_naocompilaveis FOR tt_naocompilaveis.
DEF BROWSE b_naocompilaveis QUERY q_naocompilaveis
           DISP tt_naocompilaveis.cdprogra  LABEL "Programa"    FORMAT "x(20)"
                tt_naocompilaveis.dsmotivo  LABEL "Motivo"      FORMAT "x(28)"
           WITH NO-LABEL 9 DOWN TITLE "Programas que nao sao compilados:" 
                CENTERED.

FORM "1- AYLLOS"              SKIP
     "2- CAIXA ON-LINE"       SKIP
     "3- PROGRID"             SKIP
     "4- CRM/INTERNET"        SKIP
     "5- GENERICO"            SKIP
     "6- TAA"                 SKIP
     "----------------------" SKIP
     "7- CAD. NAO COMPILAVEL" SKIP
     "----------------------" SKIP
     aux_cddopcao      LABEL "Opcao" FORMAT "9"   AT 4
                       VALIDATE(CAN-DO("1,2,3,4,5,6,7",STRING(aux_cddopcao)),"")
     HELP "1,2,3,4,5,6 - Compilar Sistemas / 7 - Cadastrar nao compilaveis"
     SKIP
     aux_tpcompil      LABEL "Compilar"
                       HELP "Informe (T)odos ou (E)scolher"
     WITH SIDE-LABELS OVERLAY FRAME f_sistema.

FORM aux_dtmvtolt    AT 08 FORMAT "99/99/9999" LABEL "Data"
     SKIP
     aux_nmprimtl    AT 01 FORMAT "x(20)"      LABEL "Responsavel"
     SKIP
     aux_dsncompi1   AT 06 FORMAT "x(37)"      LABEL "Motivo"
     SKIP
     aux_dsncompi2   AT 14 FORMAT "x(40)"      
     SKIP
     aux_cdprogra    AT 04 FORMAT "x(20)"      LABEL "Programa"
     WITH NO-LABELS SIDE-LABELS COLUMN 25 ROW 15 FRAME f_detalhes.
     
FORM b_escolhe HELP "Pressione ENTER para selecionar ou F4 para sair"
     WITH NO-BOX COLUMN 40 OVERLAY FRAME f_escolhe.
     
FORM aux_dsdlinha FORMAT "x(22)" COLUMN-LABEL "Compilando..."
     WITH DOWN COLUMN 25 OVERLAY FRAME f_compilando.
     
FORM aux_dsdlinha FORMAT "x(22)" COLUMN-LABEL "Copiando..."
     WITH DOWN column 49 OVERLAY FRAME f_copiando.
     
FORM aux_dsdbusca FORMAT "x(29)"
     WITH ROW 19 COLUMN 40 OVERLAY NO-LABEL FRAME f_busca.

FORM b_naocompilaveis 
   HELP "<ENTER> - Detalhes, <INSERT> - Incluir, <DELETE> - Excluir."
   WITH NO-LABELS NO-BOX COLUMN 25 ROW 1 FRAME f_browse.

ON ANY-KEY OF b_naocompilaveis IN FRAME f_browse
   DO:
      CLEAR FRAME f_detalhes NO-PAUSE.
      HIDE FRAME f_detalhes NO-PAUSE.
      
      ASSIGN aux_cdprogra = ""
             aux_nmprimtl = ""
             aux_dsncompi1 = ""
             aux_dsncompi2 = "".
      
      IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
          DO:
             IF  LENGTH(tt_naocompilaveis.dsmotivo) > 36  THEN
                 ASSIGN aux_dsncompi1 = 
                            SUBSTRING(tt_naocompilaveis.dsmotivo,1,36)
                        aux_dsncompi2 =
                            SUBSTRING(tt_naocompilaveis.dsmotivo,37,
                                         LENGTH(tt_naocompilaveis.dsmotivo)).
             ELSE
                 ASSIGN aux_dsncompi1 =
                            SUBSTRING(tt_naocompilaveis.dsmotivo,1,
                                     LENGTH(tt_naocompilaveis.dsmotivo)).
                                    
             ASSIGN aux_dtmvtolt = tt_naocompilaveis.dtmvtolt
                    aux_cdprogra = tt_naocompilaveis.cdprogra
                    aux_nmprimtl = tt_naocompilaveis.nmprimtl.
                          
             aux_cdprogra:VISIBLE IN FRAME f_detalhes = FALSE.
             
             DISPLAY aux_dtmvtolt  aux_nmprimtl
                     aux_dsncompi1 aux_dsncompi2
                     WITH FRAME f_detalhes.
          END.
       
      IF  KEYFUNCTION(LASTKEY) = "INSERT-MODE"  THEN
          DO:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                aux_dtmvtolt:VISIBLE IN FRAME f_detalhes = FALSE.

                UPDATE aux_nmprimtl aux_dsncompi1
                       aux_dsncompi2 aux_cdprogra  WITH FRAME f_detalhes.
                LEAVE.
             END.
        
             IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 DO:
                    HIDE FRAME f_detalhes NO-PAUSE.
                    RETURN.
                 END.

             RUN confirma-operacao.
         
             IF  RETURN-VALUE = "NOK"  THEN
                 DO:
                    HIDE FRAME f_detalhes NO-PAUSE.       
                    RETURN.
                 END.

             DO TRANSACTION ON ERROR UNDO, LEAVE:

                CREATE tt_naocompilaveis.
                ASSIGN tt_naocompilaveis.cdprogra = TRIM(aux_cdprogra)
                       tt_naocompilaveis.dsmotivo = TRIM(aux_dsncompi1 + " " + 
                                                         aux_dsncompi2)
                       tt_naocompilaveis.nmprimtl = aux_nmprimtl
                       tt_naocompilaveis.dtmvtolt = TODAY.
             END.
         
             RUN atualiza_tabela_naocompilaveis.

             ASSIGN aux_cdprogra = ""
                    aux_dsncompi1 = ""
                    aux_dsncompi2 = ""
                    aux_nmprimtl = "".
     
             OPEN QUERY q_naocompilaveis FOR EACH tt_naocompilaveis NO-LOCK.
             
             HIDE FRAME f_detalhes NO-PAUSE.

          END.
 
      IF  KEYFUNCTION(LASTKEY) = "DELETE-CHARACTER"  THEN
          DO:
              IF  QUERY q_naocompilaveis:IS-OPEN  THEN
                  ASSIGN aux_ultlinha = 
                         QUERY q_naocompilaveis:CURRENT-RESULT-ROW.
             
              FIND CURRENT tt_naocompilaveis EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
              
              IF  AVAILABLE tt_naocompilaveis   THEN
                  DO:
                     RUN confirma-operacao.

                     IF  RETURN-VALUE = "NOK"  THEN
                         DO:
                            RETURN.
                         END.
 
                      DELETE tt_naocompilaveis.
                      
                      RUN atualiza_tabela_naocompilaveis.
                  END.
              ELSE
                  RETURN.

              OPEN QUERY q_naocompilaveis FOR EACH tt_naocompilaveis NO-LOCK.

              IF  aux_ultlinha > QUERY q_naocompilaveis:NUM-RESULTS  THEN
                  ASSIGN aux_ultlinha = QUERY q_naocompilaveis:NUM-RESULTS.
   
              IF  aux_ultlinha > 0  THEN
                  REPOSITION q_naocompilaveis TO ROW aux_ultlinha.
          END.    
   END.

/* verifica as cooperativas */
FOR EACH crapcop NO-LOCK:
     
    ASSIGN  aux_nmrescop[crapcop.cdcooper] = LC(crapcop.nmrescop)
            aux_dsdircop[crapcop.cdcooper] = crapcop.dsdircop.
END.
               
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   ASSIGN aux_tpcompil:VISIBLE IN FRAME f_sistema = FALSE
          aux_nmarqlog = "/usr/coop/cecred/log/compsis_".
   
   UPDATE aux_cddopcao
          WITH FRAME f_sistema.
       
   IF  aux_cddopcao <> 7  THEN
       UPDATE aux_tpcompil WITH FRAME f_sistema.

   IF  aux_cddopcao = 1   THEN
       DO:
          ASSIGN aux_caminho  = "/usr/coop/sistema/ayllos/"
                 aux_nmarqlog = aux_nmarqlog + "ayllos.log".

          RUN carrega_arquivos(INPUT "fontes").
          RUN carrega_arquivos(INPUT "includes").
       END.
   ELSE
   IF  aux_cddopcao = 2   THEN
       DO:
           ASSIGN aux_caminho = "/usr/coop/sistema/siscaixa/"
                  aux_nmarqlog = aux_nmarqlog + "siscaixa.log".

           RUN carrega_arquivos(INPUT "web").
           RUN carrega_arquivos(INPUT "web/dbo").    
       END.
   ELSE
   IF  aux_cddopcao = 3   THEN
       DO:
           ASSIGN aux_caminho = "/usr/coop/sistema/progrid/web/"
                  aux_nmarqlog = aux_nmarqlog + "progrid.log".

           RUN carrega_arquivos(INPUT "fontes").
           RUN carrega_arquivos(INPUT "dbo").
           RUN carrega_arquivos(INPUT "zoom").
       END.
   ELSE
   IF  aux_cddopcao = 4   THEN
       DO:
           ASSIGN aux_caminho = "/usr/coop/sistema/internet/"
                  aux_nmarqlog = aux_nmarqlog + "crm_internet.log".

           RUN carrega_arquivos(INPUT "fontes").
           RUN carrega_arquivos(INPUT "procedures").
       END.
   ELSE
   IF  aux_cddopcao = 5  THEN
       DO:
           ASSIGN aux_caminho = "/usr/coop/sistema/generico/"
                  aux_nmarqlog = aux_nmarqlog + "generico.log".

           RUN carrega_arquivos(INPUT "procedures").
       END.  
   ELSE
   IF  aux_cddopcao = 6  THEN
       DO:
           ASSIGN aux_caminho = "/usr/coop/sistema/TAA/"
                  aux_nmarqlog = aux_nmarqlog + "TAA.log".

           RUN carrega_arquivos(INPUT "").
       END.  
   ELSE
       DO:
           RUN trata_naocompilaveis.
           NEXT.
       END.

   LEAVE.
   
END. /* Fim do do while true */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
     DO:
        HIDE FRAME f_sistema NO-PAUSE.
        QUIT.
     END.

IF   aux_tpcompil = NO   THEN
     RUN escolhe_arquivos.
    
/* remove o arquivo de erros */
UNIX SILENT VALUE("rm " + aux_nmarqlog + " 2> /dev/null").


/* ajusta o propath para compilar os programas */
ASSIGN aux_propath  = ",/usr/coop/sistema/siscaixa/web"        +
                      ",/usr/coop/sistema/generico"            +
                      ",/usr/coop/sistema/generico/procedures" +
                      ",/usr/coop/sistema/internet"            +
                      ",/usr/coop/sistema/internet/fontes"     +
                      ",/usr/coop/sistema/internet/procedures" +
                      ",/usr/coop/sistema/progrid/web/fontes"  +
                      ",/usr/coop/sistema/progrid/web"         +
                      ",/usr/coop/sistema/progrid".
              
propath = propath + aux_propath.              

EMPTY TEMP-TABLE tt_naocompilaveis.

/* Fontes que nao serao compilados */
RUN carrega_tabela_naocompilaveis.

FOR EACH arquivos WHERE arquivos.selected = YES NO-LOCK:

    FIND tt_naocompilaveis WHERE 
         tt_naocompilaveis.cdprogra = TRIM(arquivos.nmarquiv) NO-LOCK NO-ERROR.
         
    IF   AVAILABLE tt_naocompilaveis   THEN
         NEXT.
    
    DISP arquivos.nmarquiv @ aux_dsdlinha
         WITH FRAME f_compilando.
    
    DOWN WITH FRAME f_compilando.
    PAUSE 0.

    RUN valida_compilacao(INPUT arquivos.dsdireto,
                          INPUT arquivos.nmarquiv).

    IF  RETURN-VALUE = "OK"  THEN
        RUN compila_programa(INPUT arquivos.dsdireto,
                             INPUT arquivos.nmarquiv).
END.

/* limpa o propath */
propath = SUBSTRING(propath,1,LENGTH(propath) - LENGTH(aux_propath)).     


IF aux_flgerros THEN
   DO:
       MESSAGE "Ha programas com ERROS ou WARNINGS, visualizar?"
               UPDATE aux_confirma.
               
       IF aux_confirma THEN
          UNIX VALUE("nw " + aux_nmarqlog).
   END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   MESSAGE "Compilacao finalizada!!!".

   /* Alt. Fernando - Dar permissao no arq. de log para nao travar o script
      na proxima execucao. Somente executa esta instrucao se ocorreram erros
      de compilacao. */
   IF  SEARCH(aux_nmarqlog) <> ?  THEN
       UNIX SILENT VALUE ("chmod 666 " + aux_nmarqlog).
   
   PAUSE.
   LEAVE.
END.

/*****************************************************************************/
/*                                PROCEDURES                                 */
/*****************************************************************************/

PROCEDURE carrega_arquivos:
    DEF INPUT PARAM par_dsdireto AS CHAR                        NO-UNDO.

    INPUT STREAM str_1 THROUGH VALUE("ls " +
                                     aux_caminho  + "/" +
                                     par_dsdireto + "/~*.*") NO-ECHO.
      
    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_dsdlinha.
        
        /* se a extensao nao for ".p", ".w", ".htm" ou ".html", ignora */
        IF NOT CAN-DO("p,w,htm,html",
                       SUBSTRING(aux_dsdlinha,r-index(aux_dsdlinha,".") + 1))
                       THEN
           NEXT.
        
        /* tira o caminho retornado pelo "ls" e a extensao */
        ASSIGN aux_dsdlinha = SUBSTRING(aux_dsdlinha,
                                        R-INDEX(aux_dsdlinha,"/") + 1)
               aux_dsdlinha = SUBSTRING(aux_dsdlinha,1,
                                        LENGTH(aux_dsdlinha) - 
                                        (LENGTH(aux_dsdlinha) -
                                         R-INDEX(aux_dsdlinha,".") + 1)).
                                        
                                     
        FIND arquivos WHERE arquivos.nmarquiv = aux_dsdlinha
                            NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE arquivos   THEN
             DO TRANSACTION:
                CREATE arquivos.
                ASSIGN arquivos.dsdireto = aux_caminho + par_dsdireto
                       arquivos.nmarquiv = aux_dsdlinha
                       arquivos.selected = aux_tpcompil.
             END.
    END.

    INPUT STREAM str_1 CLOSE.
END PROCEDURE.

PROCEDURE escolhe_arquivos:

    DEF VAR aux_ultlinha AS INT         NO-UNDO.
    
    ON ANY-KEY OF b_escolhe IN FRAME f_escolhe DO:

       IF   KEYFUNCTION(LASTKEY) = "RETURN"   AND
            AVAILABLE arquivos                THEN
            DO:
                DO TRANSACTION:
                   arquivos.selected = NOT arquivos.selected.
                END.
       
                /* linha que foi deletada */
                aux_ultlinha = CURRENT-RESULT-ROW("q_escolhe").
    
                OPEN QUERY q_escolhe FOR EACH arquivos EXCLUSIVE-LOCK.
    
                /* reposiciona o browse */
                REPOSITION q_escolhe TO ROW aux_ultlinha.
            END.
       ELSE
       IF   (LASTKEY >= 65 AND LASTKEY <= 90)    OR    /* Letras Maiusculas */
            (LASTKEY >= 97 AND LASTKEY <= 122)   OR    /* Letras Minusculas */
            (LASTKEY >= 48 AND LASTKEY <= 57)    OR    /* Numeros */
            (LASTKEY  = 45)                      OR    /* Hifen */
            (LASTKEY  = 95)                      THEN  /* Underline */
            DO:
                aux_dsdbusca = aux_dsdbusca + KEYFUNCTION(LASTKEY).

                DISPLAY aux_dsdbusca WITH FRAME f_busca.

                FIND FIRST b_arquivos WHERE b_arquivos.nmarquiv
                                            BEGINS aux_dsdbusca
                                                   NO-LOCK NO-ERROR.
    
                IF   AVAILABLE b_arquivos   THEN
                     REPOSITION q_escolhe TO ROWID ROWID(b_arquivos).
            END.
       ELSE
            DO:
                aux_dsdbusca = "".
                HIDE FRAME f_busca NO-PAUSE.
            END.
    END.
    
    OPEN QUERY q_escolhe FOR EACH arquivos EXCLUSIVE-LOCK.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_escolhe WITH FRAME f_escolhe

       EDITING:

          READKEY PAUSE 1.

          /* se nao teclar nada oculta a busca */
          IF   LASTKEY = -1   THEN
               DO:
                   aux_dsdbusca = "".
                   HIDE FRAME f_busca NO-PAUSE.
               END.

          APPLY LASTKEY.
       END. /* fim do EDITING */
       
       LEAVE.
    END.
    
    CLOSE QUERY q_escolhe.
    
    HIDE FRAME f_escolhe NO-PAUSE.    
    
END PROCEDURE.

PROCEDURE compila_programa:
    
    DEF INPUT PARAM par_dsdireto AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                        NO-UNDO.
    
    DEFINE VARIABLE speedfile AS CHARACTER.
    DEFINE VARIABLE wsoptions AS CHARACTER.
    
    ASSIGN speedfile = par_dsdireto + "/" + par_nmarquiv + ".w"
           wsoptions = "".

    /* remove os arquivos .r e .off do programa */
    UNIX SILENT VALUE("rm " + par_dsdireto + "/" + par_nmarquiv +
                      ".r 2> /dev/null").
                      
    UNIX SILENT VALUE("rm " + par_dsdireto + "/" + par_nmarquiv +
                      ".off 2> /dev/null").
    
    /* compila o arquivo progress (se tiver) */
    IF   SEARCH(par_dsdireto + "/" + par_nmarquiv + ".w") <> ?   THEN
         COMPILE VALUE(par_dsdireto + "/" + par_nmarquiv + ".w") SAVE NO-ERROR.
    ELSE
    IF   SEARCH(par_dsdireto + "/" + par_nmarquiv + ".p") <> ?   THEN
         DO:
             /* nao compila o proprio compilador */
             IF  par_nmarquiv = "compila_sistemas"   OR
                 par_nmarquiv = "compila_sistemas2"  THEN
                 RETURN.

             COMPILE VALUE (par_dsdireto + "/" + par_nmarquiv + ".p") 
                           SAVE NO-ERROR.
                           
         END.
    ELSE     
    /* compila o arquivo htm ou html (se tiver) */         
    IF   SEARCH(par_dsdireto + "/" + par_nmarquiv + ".htm") <> ?   THEN
         DO:
             RUN tty/webutil/e4gl-gen.r
                            (INPUT par_dsdireto + "/" + par_nmarquiv + ".htm", 
                             INPUT-OUTPUT speedfile, 
                             INPUT-OUTPUT wsoptions).
             
             COMPILE VALUE(par_dsdireto + "/" + par_nmarquiv + ".w")
                     SAVE NO-ERROR.
                     
             UNIX SILENT VALUE("rm " + par_dsdireto + "/" + par_nmarquiv +
                               ".w 2> /dev/null").
         END.
    ELSE
    IF   SEARCH(par_dsdireto + "/" + par_nmarquiv + ".html") <> ?   then
         DO:
             RUN tty/webutil/e4gl-gen.r
                            (INPUT par_dsdireto + "/" + par_nmarquiv + ".html", 
                             INPUT-OUTPUT speedfile, 
                             INPUT-OUTPUT wsoptions).
             
             COMPILE VALUE(par_dsdireto + "/" + par_nmarquiv + ".w")
                     SAVE NO-ERROR.

             UNIX SILENT VALUE("rm " + par_dsdireto + "/" + par_nmarquiv +
                               ".w 2> /dev/null").
         END.
    ELSE
         DO:
            aux_flgerros = YES.
           
            OUTPUT stream str_2 TO value(aux_nmarqlog) APPEND.

            PUT STREAM str_2 UNFORMATTED
                par_nmarquiv " - Arquivo nao encontrado!!!"
                SKIP(1).
           
            OUTPUT STREAM str_2 CLOSE.
            LEAVE.
         END.


    /* erro de compilacao */
    IF SEARCH(par_dsdireto + "/" + par_nmarquiv + ".r") = ? THEN
       DO:
           aux_flgerros = YES.
           
           OUTPUT stream str_2 TO value(aux_nmarqlog) append.

           DO aux_qtderros = 1 TO ERROR-STATUS:NUM-MESSAGES:
              
              PUT STREAM str_2 UNFORMATTED
                  par_nmarquiv " - "
                  ERROR-STATUS:GET-MESSAGE(aux_qtderros)
                  SKIP.
           END.
           
           PUT STREAM str_2 SKIP(1).
           
           OUTPUT STREAM str_2 CLOSE.
           LEAVE.
       END.
    ELSE
       DO:
          /* Alteracao Fernando - caso nao tenha erro, dar permissao no .r .
             Existia um problema com alguns usuario na hora de compilar, pois
             o owner do arquivo fica com quem compila, assim quando foce abrir o
             compsis com outro usuario o script travava */
       
          UNIX SILENT VALUE("chmod 666 " + par_dsdireto + "/" +
                                           par_nmarquiv + ".r").
                                           
                                           
          /* Verifica se houve algum WARNING */
          OUTPUT stream str_2 TO VALUE(aux_nmarqlog) APPEND.

          DO aux_qtderros = 1 TO ERROR-STATUS:NUM-MESSAGES:

             aux_flgerros = YES.
             
             PUT STREAM str_2 UNFORMATTED
                              par_nmarquiv " - "
                              ERROR-STATUS:GET-MESSAGE(aux_qtderros)
                              SKIP.
                              
             IF  aux_qtderros = ERROR-STATUS:NUM-MESSAGES  THEN
                 PUT STREAM str_2 SKIP(1).

          END.
                      
          OUTPUT STREAM str_2 CLOSE.
       
       END.
                                                  
    /* gera o .off para a URA */
    IF par_nmarquiv = "URA" THEN
       DO:
           OUTPUT STREAM str_2 to VALUE(par_dsdireto + "/" +
                                        par_nmarquiv + ".off").
           
           PUT STREAM str_2 UNFORMATTED
                            "~/~* HTML offsets *~/" SKIP
                            "htm-file= "
                            par_dsdireto + "/" + par_nmarquiv
                            ".off"                 SKIP
                            "version= "            SKIP.
           
           OUTPUT STREAM str_2 CLOSE.
       END.
       
       
    /* gera o .off para o CQL */
    IF par_nmarquiv = "CQL" THEN
       DO:
           OUTPUT STREAM str_2 to VALUE(par_dsdireto + "/" +
                                        par_nmarquiv + ".off").
           
           PUT STREAM str_2 UNFORMATTED
                            "~/~* HTML offsets *~/" SKIP
                            "htm-file= "
                            par_dsdireto + "/" + par_nmarquiv
                            ".off"                 SKIP
                            "version= "            SKIP.
           
           OUTPUT STREAM str_2 CLOSE.
       END.
       
    
    /*********************************************************
     
                          FERNANDO KLOCK
       Criado link na PRODUCAO, desativada a copia de fontes
      
       Copia os programas compilados para as cooperativas, exceto ayllos
       e progrid que possuem diretorios unificados 
    IF  aux_cddopcao <> 1 AND
        aux_cddopcao <> 3 THEN
        DO aux_contador = 1 TO 99:
                    
           IF  aux_nmrescop[aux_contador] <> ""  THEN
               DO:
                   DISP UPPER(aux_nmrescop[aux_contador]) @ aux_dsdlinha
                        WITH FRAME f_copiando.

                   DOWN WITH FRAME f_copiando.
                   PAUSE 0.
                   
                   IF   OS-GETENV("PKGNAME") = "pkgprod"  THEN 
                        DO:
                            /* generico e internet */ 
                            IF aux_cddopcao = 4 OR
                               aux_cddopcao = 5 THEN    
                               DO:
                            /* remove os arquivos antigos antes de copiar */
                            UNIX SILENT VALUE("rm -f " +
                                 SUBSTRING(par_dsdireto,1,
                                        INDEX(par_dsdireto,"sistema") - 1) +
                                 aux_dsdircop[aux_contador] + "/" +
                                 SUBSTRING(par_dsdireto,
                                        INDEX(par_dsdireto,"sistema")) +
                                 "/" + par_nmarquiv + "* " +
                                 "2> /dev/null").
                   
                   
                            /* copia */
                            UNIX SILENT VALUE("cp -p -f " + 
                                 par_dsdireto + "/" +
                                 par_nmarquiv + "* " +
                                 SUBSTRING(par_dsdireto,1,
                                        INDEX(par_dsdireto,"sistema") - 1) +
                                 aux_dsdircop[aux_contador] + "/" +
                                 SUBSTRING(par_dsdireto,
                                        INDEX(par_dsdireto,"sistema")) +
                                 " 2> /dev/null").
                               END.
                            ELSE
                               DO:
                            /* siscaixa */
                            /* remove os arquivos antigos antes de copiar */
                            UNIX SILENT VALUE("rm -f " +
                                 REPLACE(par_dsdireto,"sistema",
                                         aux_dsdircop[aux_contador]) +
                                 "/" + par_nmarquiv + "* " +
                                 "2> /dev/null").
                   
                   
                            /* copia */
                            UNIX SILENT VALUE("cp -p -f " + 
                                 par_dsdireto + "/" +
                                 par_nmarquiv + "* " +
                                 REPLACE(par_dsdireto,"sistema",
                                         aux_dsdircop[aux_contador])  + "/" +
                                 " 2> /dev/null").
                               END.
                        END. 
               END.
        END.

    /* limpa o frame */
    DOWN 17 WITH FRAME f_copiando.
    PAUSE 0.

    ************************************************/
    
END PROCEDURE.



PROCEDURE valida_compilacao:
    
    DEF INPUT PARAM par_dsdireto AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                        NO-UNDO.
    
     
    DEFINE VARIABLE speedfile    AS CHARACTER                   NO-UNDO.
    DEFINE VARIABLE wsoptions    AS CHARACTER                   NO-UNDO.

    DEFINE VARIABLE aux_dsdirtmp AS CHAR                        NO-UNDO.
    
    ASSIGN speedfile    = par_dsdireto + "/" + par_nmarquiv + ".w"
           wsoptions    = ""
           aux_dsdirtmp = "/usr/coop/sistema/compilacao".

    /* remove os arquivos .r e .off do programa no diretorio temporario */
    UNIX SILENT VALUE("rm " + aux_dsdirtmp + "/" + par_nmarquiv +
                      ".r 2> /dev/null").
                      
    UNIX SILENT VALUE("rm " + aux_dsdirtmp + "/" + par_nmarquiv +
                      ".off 2> /dev/null").

    /* compila o arquivo progress (se tiver) */
    IF   SEARCH(par_dsdireto + "/" + par_nmarquiv + ".w") <> ?   THEN
         COMPILE VALUE(par_dsdireto + "/" + par_nmarquiv + ".w") SAVE INTO VALUE(aux_dsdirtmp) NO-ERROR.
    ELSE
    IF   SEARCH(par_dsdireto + "/" + par_nmarquiv + ".p") <> ?   THEN
         DO:
             /* nao compila o proprio compilador */
             IF  par_nmarquiv = "compila_sistemas"   OR
                 par_nmarquiv = "compila_sistemas2"  THEN
                 RETURN.

             COMPILE VALUE (par_dsdireto + "/" + par_nmarquiv + ".p") 
                           SAVE INTO VALUE(aux_dsdirtmp) NO-ERROR.
         END.
    ELSE     
    /* compila o arquivo htm ou html (se tiver) */         
    IF   SEARCH(par_dsdireto + "/" + par_nmarquiv + ".htm") <> ?   THEN
         DO:
             RUN tty/webutil/e4gl-gen.r
                            (INPUT par_dsdireto + "/" + par_nmarquiv + ".htm", 
                             INPUT-OUTPUT speedfile, 
                             INPUT-OUTPUT wsoptions).
             
             COMPILE VALUE(par_dsdireto + "/" + par_nmarquiv + ".w")
                     SAVE INTO VALUE(aux_dsdirtmp) NO-ERROR.
                     
             UNIX SILENT VALUE("rm " + par_dsdireto + "/" + par_nmarquiv +
                               ".w 2> /dev/null").
         END.
    ELSE
    IF   SEARCH(par_dsdireto + "/" + par_nmarquiv + ".html") <> ?   then
         DO:
             RUN tty/webutil/e4gl-gen.r
                            (INPUT par_dsdireto + "/" + par_nmarquiv + ".html", 
                             INPUT-OUTPUT speedfile, 
                             INPUT-OUTPUT wsoptions).
             
             COMPILE VALUE(par_dsdireto + "/" + par_nmarquiv + ".w")
                     SAVE INTO VALUE(aux_dsdirtmp) NO-ERROR.

             UNIX SILENT VALUE("rm " + par_dsdireto + "/" + par_nmarquiv +
                               ".w 2> /dev/null").
         END.
    ELSE
         DO:
            aux_flgerros = YES.
           
            OUTPUT stream str_2 TO value(aux_nmarqlog) APPEND.

            PUT STREAM str_2 UNFORMATTED
                par_nmarquiv " - Arquivo nao encontrado!!!"
                SKIP(1).
           
            OUTPUT STREAM str_2 CLOSE.
            
            RETURN "NOK".
         END.


    /* erro de compilacao */
    IF SEARCH(aux_dsdirtmp + "/" + par_nmarquiv + ".r") = ? THEN
       DO:
           aux_flgerros = YES.
           
           OUTPUT stream str_2 TO value(aux_nmarqlog) append.

           DO aux_qtderros = 1 TO ERROR-STATUS:NUM-MESSAGES:
              
              PUT STREAM str_2 UNFORMATTED
                  par_nmarquiv " - "
                  ERROR-STATUS:GET-MESSAGE(aux_qtderros)
                  SKIP.
           END.
           
           PUT STREAM str_2 SKIP(1).
           
           OUTPUT STREAM str_2 CLOSE.

           RETURN "NOK".
       END.
    ELSE
       DO:
          /* Caso nao tenha erro, remove o .r */
          UNIX SILENT VALUE("rm " + aux_dsdirtmp + "/" + par_nmarquiv + ".r 2> /dev/null").
                                           
          /* Verifica se houve algum WARNING */
          OUTPUT stream str_2 TO VALUE(aux_nmarqlog) APPEND.

          DO aux_qtderros = 1 TO ERROR-STATUS:NUM-MESSAGES:

             aux_flgerros = YES.
             
             PUT STREAM str_2 UNFORMATTED
                              par_nmarquiv " - "
                              ERROR-STATUS:GET-MESSAGE(aux_qtderros)
                              SKIP.
                              
             IF  aux_qtderros = ERROR-STATUS:NUM-MESSAGES  THEN
                 PUT STREAM str_2 SKIP(1).

          END.
                      
          OUTPUT STREAM str_2 CLOSE.
       END.
                                                  
    RETURN "OK".

END PROCEDURE.





PROCEDURE trata_naocompilaveis:

 DEF VAR aux_cdprogra  AS CHAR                       NO-UNDO.
 DEF VAR aux_dsncompi1 AS CHAR                       NO-UNDO.
 DEF VAR aux_dsncompi2 AS CHAR                       NO-UNDO.
 
 EMPTY TEMP-TABLE tt_naocompilaveis.
 
 RUN carrega_tabela_naocompilaveis.

 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    OPEN QUERY q_naocompilaveis FOR EACH tt_naocompilaveis NO-LOCK
                                    BY tt_naocompilaveis.cdprogra.
    ENABLE b_naocompilaveis WITH FRAME f_browse.
    
    WAIT-FOR RETURN OF b_naocompilaveis.
      
    HIDE b_naocompilaveis NO-PAUSE.

 END. /* Fim do DO WHILE TRUE */

 IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
     DO:
        HIDE FRAME f_browse NO-PAUSE.
        RETURN.
     END.
   
END PROCEDURE.

PROCEDURE atualiza_tabela_naocompilaveis:

  OUTPUT STREAM str_3 TO 
        VALUE("/usr/local/cecred/etc/TabelaDeProgramasNaoCompilaveis") NO-ECHO.
  
  PUT STREAM str_3 UNFORMATTED 
      "# Tabela para programas nao compilaveis no COMPSIS." SKIP.

  FOR EACH tt_naocompilaveis NO-LOCK:
  
      PUT STREAM str_3 UNFORMATTED
          tt_naocompilaveis.cdprogra + ";" +
          tt_naocompilaveis.dsmotivo + ";" +
          tt_naocompilaveis.nmprimtl + ";" +
          STRING(tt_naocompilaveis.dtmvtolt) SKIP.

  END. /* Fim do FOR EACH */

  OUTPUT STREAM str_3 CLOSE.
  
END PROCEDURE.

PROCEDURE carrega_tabela_naocompilaveis:

  INPUT STREAM str_3 FROM 
        VALUE("/usr/local/cecred/etc/TabelaDeProgramasNaoCompilaveis") NO-ECHO.
      
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
  
      IMPORT STREAM str_3 UNFORMATTED aux_dsarquiv.

      /* Comentarios dentro do arquivo devem ser descartados */
      IF   aux_dsarquiv MATCHES "#*"  THEN
           NEXT.

      CREATE tt_naocompilaveis.
      ASSIGN tt_naocompilaveis.cdprogra = TRIM(ENTRY(1,aux_dsarquiv,";"))
             tt_naocompilaveis.dsmotivo = TRIM(ENTRY(2,aux_dsarquiv,";"))
             tt_naocompilaveis.nmprimtl = TRIM(ENTRY(3,aux_dsarquiv,";"))
             tt_naocompilaveis.dtmvtolt = DATE(TRIM(ENTRY(4,aux_dsarquiv,";"))).
                        
   END.  /*  Fim do DO WHILE TRUE  */
                        
   INPUT STREAM str_3 CLOSE.

END PROCEDURE. 

PROCEDURE confirma-operacao:

    ASSIGN aux_confirma = YES.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        MESSAGE "Confirma a operacao? (S/N):" UPDATE aux_confirma.
        LEAVE.
    
    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
        aux_confirma <> YES                 THEN
        DO:
            MESSAGE "Operacao nao efetuada.".
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.
/* .......................................................................... */
