/* .............................................................................

   Programa: Fontes/prctan.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas
   Data    : Março/2012.                     Ultima atualizacao: 06/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Envio de arquivos para TAN.

   Alteracoes: 05/04/2012 - Alteração na Temp Table que estava replicando
                            informações na opção C. (David Kruger).
                            
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF    VAR aux_loglinha  AS CHAR                                         NO-UNDO.
DEF    VAR aux_cddopcao  AS CHAR                                         NO-UNDO.
DEF    VAR aux_nmendere  AS CHAR                                         NO-UNDO.
DEF    VAR aux_nmarquiv  AS CHAR                                         NO-UNDO.
DEF    VAR aux_nmarqsel  AS CHAR                                         NO-UNDO.
DEF    VAR aux_confirma  AS CHAR     FORMAT "!"                          NO-UNDO.
DEF    VAR aux_contador  AS INT                                          NO-UNDO.
DEF    VAR aux_mespesqu  AS CHAR     FORMAT "x(2)"                       NO-UNDO.
DEF    VAR aux_anopesqu  AS CHAR     FORMAT "x(4)"                       NO-UNDO.
DEF    VAR aux_datapesq  AS DATE                                         NO-UNDO.

DEF TEMP-TABLE tt-arquivos                                               NO-UNDO
    FIELD nmarquiv AS CHAR FORMAT "x(45)"
    FIELD idseqite AS INT.

DEF TEMP-TABLE tt-arquivos_sel                                           NO-UNDO
    FIELD nmarqusl AS CHAR FORMAT "x(45)"
    FIELD idseqite AS INT.

DEF TEMP-TABLE tt-log                                                    NO-UNDO
    FIELD dtenvarq AS CHAR FORMAT "x(10)"
    FIELD hrenvarq AS CHAR FORMAT "x(5)"
    FIELD nmarquiv AS CHAR FORMAT "x(70)"
    FIELD statusar AS CHAR FORMAT "x(7)"
    FIELD dscritic AS CHAR FORMAT "x(70)".

DEF QUERY q_arquivos  FOR  tt-arquivos.
DEF QUERY q_log  FOR  tt-log.

DEF BROWSE b_arquivos QUERY q_arquivos
    DISP tt-arquivos.nmarquiv COLUMN-LABEL "NOME"
    WITH 10 DOWN WIDTH 50 COLUMN 15 OVERLAY TITLE " Arquivos Disponíveis "  MULTIPLE. 


DEF BROWSE b_log QUERY q_log 
    DISP tt-log.dtenvarq COLUMN-LABEL "DATA"    FORMAT "x(10)"
         tt-log.hrenvarq COLUMN-LABEL "HORA"    FORMAT "x(5)"
         tt-log.dscritic COLUMN-LABEL "ACAO"    FORMAT "x(70)"
         tt-log.nmarquiv COLUMN-LABEL "ARQUIVO" FORMAT "x(70)" 
         tt-log.statusar COLUMN-LABEL "STATUS"  FORMAT "x(7)"         
         WITH 6 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF FRAME f_log
          b_log
    HELP "Pressione <SETAS> p/ outras navegar "
    WITH NO-BOX CENTERED OVERLAY ROW 8.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM  SKIP(1)
      glb_cddopcao AT 5 LABEL "Opcao" AUTO-RETURN
                         HELP "Entre com a opcao desejada (T ou C)"
                         VALIDATE(CAN-DO("T,C",glb_cddopcao),
                                  "014 - Opcao errada.")
      SKIP(4)
      WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_prctan.

FORM  "Data:"
      aux_mespesqu NO-LABEL FORMAT "x(2)"
                   HELP "Insira um mes."
                   VALIDATE(NOT CAN-DO("",aux_mespesqu),
                                  "Insira um mes para pesquisar") 
      "/"
      aux_anopesqu NO-LABEL AUTO-RETURN FORMAT "x(4)"
                   HELP "Insira um ano."
                   VALIDATE(NOT CAN-DO("",aux_anopesqu),
                                  "Insira um ano para pesquisar.")

      WITH ROW 6 COLUMN 18 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_opcao_c.

FORM SKIP(1)
     b_arquivos  
     HELP "<ESPACO> Marcar/Desmarcar <F4> Retornar"
     WITH NO-BOX CENTERED OVERLAY ROW 6 WIDTH 50 FRAME f_arquivos SIDE-LABELS.


FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
VIEW FRAME f_moldura. 
PAUSE(0).

RUN fontes/inicia.p. 

ASSIGN glb_cddopcao = "T"
       glb_cdcritic = 0.

DO WHILE TRUE:

     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       UPDATE glb_cddopcao WITH FRAME f_prctan.

       IF  glb_cddepart <> 20 AND   /* TI            */
           glb_cddepart <>  6 AND   /* CONTABILIDADE */ 
           glb_cddepart <> 14 THEN  /* PRODUTOS      */
           DO:
              glb_cdcritic = 36.
              RUN fontes/critic.p.
              MESSAGE glb_dscritic.
              PAUSE 2 NO-MESSAGE.
              glb_cdcritic = 0.
              NEXT.
           END.
       LEAVE.
     END.

     IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
       DO:
           RUN fontes/novatela.p.
           IF CAPS(glb_nmdatela) <> "PRCTAN"   THEN
              DO:
                HIDE FRAME f_prctan.
                RETURN.
              END.
           ELSE
                NEXT.
       END.

IF   aux_cddopcao <> glb_cddopcao THEN
     DO:
       { includes/acesso.i }
       aux_cddopcao = glb_cddopcao.
     END.

        /* Opção T */
IF   glb_cddopcao = "T"   THEN
     DO:
           
       /* listagem dos arquivos */
       ASSIGN aux_nmendere = "/micros/cecred/contab/"
              aux_nmarquiv = aux_nmendere + "*SCR2.3046*.zip"
              aux_contador = 0.
                                                                         
       INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

       DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

           IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

           ASSIGN aux_contador = aux_contador + 1.

           CREATE tt-arquivos.
           ASSIGN tt-arquivos.nmarquiv = TRIM(SUBSTRING(aux_nmarquiv, 23))
                  tt-arquivos.idseqite = aux_contador.

       END.

       INPUT STREAM str_1 CLOSE.

       OPEN QUERY q_arquivos FOR EACH tt-arquivos                                 
                                  BY tt-arquivos.idseqite.
       
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           UPDATE b_arquivos WITH FRAME f_arquivos.
                          
           LEAVE.
       END.

       DO:
           DO TRANSACTION
                aux_contador = 1 TO
                b_arquivos:NUM-SELECTED-ROWS:
          
                b_arquivos:FETCH-SELECTED-ROW(
                                  aux_contador).

                CREATE tt-arquivos_sel.
                ASSIGN tt-arquivos_sel.nmarqusl = tt-arquivos.nmarquiv
                        tt-arquivos_sel.idseqite = aux_contador.
                                 
           END.                

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" AND
                AVAIL tt-arquivos_sel THEN
                DO:
                    
                    ASSIGN aux_confirma = "N".
                    RUN fontes/confirma.p (INPUT  "",
                                OUTPUT aux_confirma).
           
                    IF  aux_confirma = "S" THEN 
                        DO:
                   
                           FOR EACH tt-arquivos_sel NO-LOCK:
                               
                               IF tt-arquivos_sel.idseqite = 1 THEN DO:
                                   ASSIGN aux_nmarqsel = aux_nmendere + tt-arquivos_sel.nmarqusl.
                                   NEXT.
                               END.
           
                               ASSIGN aux_nmarqsel = aux_nmarqsel + "," + aux_nmendere + tt-arquivos_sel.nmarqusl.
           
                           END.

                        /* Executa o script de envio pelo FTP */
                           MESSAGE COLOR NORMAL "Enviando....".
                           UNIX SILENT VALUE("/usr/local/cecred/bin/ftptan_envia_ttm.pl -arquivo " + aux_nmarqsel) NO-ECHO.   
                           HIDE MESSAGE NO-PAUSE.   
                        END.
                
                END.
           ELSE 
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
                    BELL.
                    MESSAGE glb_dscritic.
                END.
       END.
     
     END.

        /* Opção C */
IF   glb_cddopcao = "C"   THEN
     DO:

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
           UPDATE aux_mespesqu aux_anopesqu WITH FRAME f_opcao_c.
           
           ASSIGN aux_datapesq = DATE("01/" + aux_mespesqu + "/" + aux_anopesqu).
         
           /* listagem dos arquivos */
           ASSIGN aux_nmarquiv = "/usr/coop/cecred/log/ftptan_envia_ttm.log".
                                                                  
           INPUT STREAM str_2 FROM VALUE(aux_nmarquiv) NO-ECHO.
           
           EMPTY TEMP-TABLE tt-log.

           DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                
                IMPORT STREAM str_2 UNFORMATTED aux_loglinha.  
         
                CREATE tt-log.
         
                /* Monta DATA */
                ASSIGN tt-log.dtenvarq = SUBSTRING(aux_loglinha,8,2) /* Obtem dia */
                       tt-log.dtenvarq = tt-log.dtenvarq + "/" + SUBSTRING(aux_loglinha,6,2) /* Obtem mes */
                       tt-log.dtenvarq = tt-log.dtenvarq + "/" + SUBSTRING(aux_loglinha,2,4).  /* Obtem ano */
                
                /* Monta HORA */
                ASSIGN tt-log.hrenvarq = SUBSTRING(aux_loglinha,11,5).
             
                /* Monta NOME */
                ASSIGN tt-log.nmarquiv = SUBSTRING(aux_loglinha,105,70).

                /* Monta STATUS */
                ASSIGN tt-log.statusar = SUBSTRING(aux_loglinha,176,12).

                /* Monta CRITICA */
                ASSIGN tt-log.dscritic = SUBSTRING(aux_loglinha,34,70).

           END.

           INPUT STREAM str_2 CLOSE.
           
           OPEN QUERY q_log FOR EACH tt-log WHERE tt-log.dtenvarq MATCHES 
                                            "*" + STRING(STRING(MONTH(aux_datapesq)) + "/" 
                                                         + STRING(YEAR(aux_datapesq))) NO-LOCK.
         
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                ENABLE  b_log WITH FRAME f_log.                    
                WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                LEAVE.
         
           END.
           HIDE FRAME f_log.
         
           NEXT.
       END.
    
     END.
    
LEAVE.
END.
