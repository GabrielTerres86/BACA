/* ............................................................................

   Programa: Fontes/dscusr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise)
   Data    : Abril/2008                         Ultima alteracao: 01/12/2016
   
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Tela para efetuar a desconexao das sessoes dos usuarios 
   
   Atualizacoes: 23/01/2009 - Retirar permissao do operador 799 e permitida ao
                              979 (Gabriel).
                              
                 25/05/2009 - Alteracao CDOPERAD (Kbase).

                 31/07/2009 - Alteracao do diretorio do banco - Unificacao
                              (Julio).
                              
                 17/02/2010 - Usar o banco conforme a cooperativa que estiver
                              unificada (Evandro).
                              
                 24/01/2011 - Utilizar ENTRY para buscar dados da conexao do 
                              usuario (Guilherme).
                              
                 24/03/2014 - Ajuste para desconectar o usuario do banco ORACLE
                              (Fernando).
                              
                 19/08/2014 - Alteração na passagem de parametro para o script
                              search_dscusr.sh para nao precisar ler todos os 
                              servidores para derrubar o usuario (Elton).   
                              
                 19/11/2014 - Ajustes referente ao softdesk 222163:
                              - Enviar o codigo do usuario como parametro para 
                                o script disconnect_dscusr.sh;
                              - Nao deixar estourar na tela o erro que eh 
                                apresentado pelo Unix quando o usuario
                                nao tiver permissao de execucao dos
                                scripts utilizados nesta.
                              (Adriano).             
                 
                 24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).     
                 
                 01/12/2016 - Alterado campo dsdepart para cddepart.
                              PRJ341 - BANCENJUD (Odirlei-AMcom)
............................................................................ */

{ includes/var_online.i }

DEF VAR tel_cdusuari AS CHAR    FORMAT "x(8)"                        NO-UNDO.
DEF VAR tel_nmusuari AS CHAR    FORMAT "x(50)"                       NO-UNDO.
DEF VAR aux_stimeout AS INT                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_query    AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqerr AS CHAR                                         NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                         NO-UNDO.

DEF TEMP-TABLE cratusr NO-UNDO
    FIELD nmclustr AS CHAR FORMAT "X(15)"
    FIELD dshorcon AS CHAR FORMAT "X(08)"
    FIELD dstermin AS CHAR FORMAT "X(30)"
    FIELD nrconexa AS INT  FORMAT "999999".
                      
DEF VAR aux_nmclustr LIKE cratusr.nmclustr NO-UNDO.
DEF VAR aux_dshorcon LIKE cratusr.dshorcon NO-UNDO.
DEF VAR aux_dstermin LIKE cratusr.dstermin NO-UNDO.
DEF VAR aux_nrconexa LIKE cratusr.nrconexa NO-UNDO.

DEF VAR aux_nmdirban AS CHAR               NO-UNDO.

DEF        VAR aux_dslinha  AS CHAR   FORMAT "x(75)"                 NO-UNDO.
DEF STREAM str_1. /* Arquivo importado */
DEF STREAM str_2. /* Arquivo de erro */

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_cdusuari AT  2 LABEL "Usuario"
                        HELP "Entre com o login do usuario"
     tel_nmusuari AT  20 NO-LABEL
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_param.

DEF VAR resp AS LOGICAL FORMAT "SIM/NAO" INIT FALSE
                        LABEL " Confirma desconexao da sessao do usuario?"
                        NO-UNDO.
     
DEF QUERY q_cratusr FOR cratusr FIELDS(dshorcon
                                       dstermin
                                       nrconexa).
 
DEF BROWSE b_cratusr QUERY q_cratusr 
    DISP cratusr.dshorcon COLUMN-LABEL "Hora"         FORMAT "x(08)"
         cratusr.dstermin COLUMN-LABEL "Terminal"     FORMAT "x(30)"
         cratusr.nrconexa COLUMN-LABEL "Conexao  "    FORMAT "99999"
         WITH 9 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF FRAME f_cratusr
          b_cratusr  
    HELP "Pressione <ENTER> para efetuar desconexao da sessao "
    WITH NO-BOX CENTERED OVERLAY ROW 8.


ASSIGN aux_nmdirban = "/usr/coop/bdados/prd/progress/ayllos/ayllos".


ON ENTER OF b_cratusr IN FRAME f_cratusr
   DO:                       
       IF NOT AVAILABLE cratusr   THEN
          RETURN NO-APPLY.

       UPDATE resp WITH ROW 22 COLUMN 15 NO-BOX OVERLAY
              SIDE-LABELS FRAME f_resp.
       HIDE FRAME f_resp.
       
       IF resp THEN 
          DO:
            ASSIGN aux_nmclustr = cratusr.nmclustr
                   aux_dshorcon = cratusr.dshorcon
                   aux_dstermin = cratusr.dstermin
                   aux_nrconexa = cratusr.nrconexa.

            UNIX SILENT VALUE("sudo /usr/local/cecred/bin/disconnect_dscusr.sh "
                              + aux_nmclustr + " " + STRING(cratusr.nrconexa) + 
                              " " + tel_cdusuari + " > " + aux_nmarquiv).

            RUN gera_log (INPUT aux_dshorcon,
                          INPUT aux_dstermin,
                          INPUT aux_nrconexa). 
            
            RUN busca_sessoes(OUTPUT glb_dscritic).

            IF RETURN-VALUE <> "OK" THEN
               DO:
                  IF glb_dscritic <> '' THEN
                     DO:
                        MESSAGE glb_dscritic.
                        PAUSE 3 NO-MESSAGE.

                        ASSIGN glb_cdcritic = 0 
                               glb_dscritic = ''.
                     END.
                  ELSE 
                     DO:
                        MESSAGE "Nao foi possivel consultar as sessoes!".
                        PAUSE 3 NO-MESSAGE.

                     END.

                  APPLY "END-ERROR".
                  RETURN.
                  
               END.

          END.

       APPLY "ENTRY" TO b_cratusr IN FRAME f_cratusr.
       HIDE MESSAGE NO-PAUSE.

   END.

VIEW FRAME f_moldura.

PAUSE(0).

/* Usado para criticar acesso aos operadadores */
ASSIGN glb_cddopcao = "E"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0.
           END.

      UPDATE tel_cdusuari 
             WITH FRAME f_param.
      
      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i }
               aux_cddopcao = glb_cddopcao.
           END.

      IF   glb_cddepart <> 20 AND   /* TI                  */
           glb_cddepart <>  9 AND   /* COORD.PRODUTOS      */
           glb_cddepart <> 18 AND   /* SUPORTE             */
           glb_cddepart <>  8 AND   /* COORD.ADM/FINANCEIRO*/
           glb_cddepart <>  1 THEN  /* CANAIS              */
           DO:
              ASSIGN glb_cdcritic = 36.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              ASSIGN glb_cdcritic = 0.
              NEXT.
           END.
           
      /* Consistencias de usuarios informados */
      IF UPPER(tel_cdusuari) = "ROOT" OR
         UPPER(SUBSTR(tel_cdusuari, 1, 4)) = "CASH" THEN 
         DO:
             MESSAGE "Nao eh permitido consultar este usuario !".
             NEXT.
         END.
         
      IF LENGTH(tel_cdusuari) <> 8 THEN 
         DO:
             MESSAGE "Usuario informado eh invalido !".
             NEXT.
         END.
      
      ASSIGN aux_nmarquiv = "arq/dscusr" + STRING(TIME)
             aux_nmarqerr = "arq/dscusr_erro" + STRING(TIME).
      
      RUN busca_nome_usuario.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
         RUN busca_sessoes(OUTPUT glb_dscritic).

         IF RETURN-VALUE <> "OK" THEN
            DO:
               IF glb_dscritic <> '' THEN
                  DO:
                     MESSAGE glb_dscritic.

                     ASSIGN glb_cdcritic = 0 
                            glb_dscritic = ''.
                  END.
               ELSE 
                  MESSAGE "Nao foi possivel consultar as sessoes!".

               LEAVE.

            END.
                 
         FIND FIRST cratusr NO-LOCK NO-ERROR.

         IF NOT AVAIL cratusr THEN 
            DO:
                MESSAGE "Usuario nao possui sessoes abertas no momento !".
                LEAVE.
            END.

         ENABLE b_cratusr WITH FRAME f_cratusr.
                 
         WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

         HIDE FRAME f_cratusr.
         
         HIDE MESSAGE NO-PAUSE.
         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "DSCUSR"  THEN
                 DO:
                     HIDE FRAME f_param.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
END.

PROCEDURE busca_sessoes.
                     
   DEF OUTPUT PARAM par_dscritic AS CHAR                            NO-UNDO.

   EMPTY TEMP-TABLE cratusr.

   ASSIGN aux_tamarqui = "".
                                                         
   UNIX SILENT VALUE("sudo /usr/local/cecred/bin/search_dscusr.sh " +  
                     tel_cdusuari + " > " + aux_nmarquiv + " 2>" + 
                     aux_nmarqerr).
                                                           
   /* Verifica se houve algum erro ao buscar as sessoes do usuario */
   INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_nmarqerr + " 2>/dev/null") 
                                    NO-ECHO.

   SET STREAM str_2 aux_tamarqui FORMAT "X(30)".
   
   /*Se houve erro na chamada do script, remove o arquivo de erro.*/
   IF SEARCH(aux_nmarqerr) <> ? THEN
      UNIX SILENT VALUE("rm " + aux_nmarqerr + " 2> /dev/null").
     
   INPUT STREAM str_2 CLOSE. 

   IF INT(SUBSTRING(aux_tamarqui,1,1)) <> 0 THEN
      DO:
         ASSIGN par_dscritic = "Erro ao consultar as sessoes!".
           
         /*Remove arquivo utilizado pelo script para armazenar as informacoes
           das sessoes.*/
         UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

         RETURN "NOK".
      END.
         
   /* Converte o arquivo de DOS para UNIX */
   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + 
                     aux_nmarquiv + "_ux").

   ASSIGN aux_nmarquiv = aux_nmarquiv + "_ux".

   /* Cria copia do arquivo como QUOTER  */
   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " + 
                     aux_nmarquiv + "_q").

   ASSIGN aux_nmarquiv = aux_nmarquiv + "_q".

   INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.
  
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
   
      IMPORT STREAM str_1 aux_dslinha.
   
      CREATE cratusr.
      ASSIGN cratusr.dshorcon = ENTRY(1,aux_dslinha,";")
             cratusr.dstermin = ENTRY(2,aux_dslinha,";")
             cratusr.nrconexa = INT(ENTRY(3,aux_dslinha,";"))
             cratusr.nmclustr = ENTRY(4,aux_dslinha,";") .
   
   END.  /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_1 CLOSE.

   /* remove o arquivo QUOTER */ 
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   /* volta o nome para o arquivo UNIX e o remove */
   ASSIGN aux_nmarquiv = SUBSTRING(aux_nmarquiv,1,LENGTH(aux_nmarquiv) - 2).
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   /* volta o nome para o arquivo original e remove */
   ASSIGN aux_nmarquiv = SUBSTRING(aux_nmarquiv,1,LENGTH(aux_nmarquiv) - 3).
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").
   
   ASSIGN aux_query = "FOR EACH cratusr NO-LOCK".
   QUERY q_cratusr:QUERY-CLOSE().
   QUERY q_cratusr:QUERY-PREPARE(aux_query).

   MESSAGE "Aguarde...".
   QUERY q_cratusr:QUERY-OPEN().
         
   HIDE MESSAGE NO-PAUSE.

   RETURN "OK".

END PROCEDURE.

PROCEDURE gera_log:

    DEF INPUT PARAM par_dshorcon AS CHAR                          NO-UNDO.
    DEF INPUT PARAM par_dstermin AS CHAR                          NO-UNDO.
    DEF INPUT PARAM par_nrconexa AS CHAR                          NO-UNDO.
    
    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      " Operador " + glb_cdoperad + " desconectou sessao do" +
                      " usuario: " + tel_cdusuari +
                      ", conectada as: " + STRING(par_dshorcon,"x(8)") + 
                      ", no terminal: " + STRING(par_dstermin,"x(30)") +
                      ", conexao: " + STRING(par_nrconexa,"99999") + 
                      " >> log/dscusr.log").

END PROCEDURE.

PROCEDURE busca_nome_usuario:
   
   UNIX SILENT VALUE ("pwget -n " + tel_cdusuari + 
                      "| awk -F: '" + chr(123) + " print $5 " + chr(125) + 
                      "' > " + aux_nmarquiv).

   /* Converte o arquivo de DOS para UNIX */
   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + 
                     aux_nmarquiv + "_ux").

   ASSIGN aux_nmarquiv = aux_nmarquiv + "_ux".

   /* Cria copia do arquivo como QUOTER  */
   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " + 
                     aux_nmarquiv + "_q").

   ASSIGN aux_nmarquiv = aux_nmarquiv + "_q"
          aux_dslinha = "". 
   
   INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.
         
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
   
      IMPORT STREAM str_1 aux_dslinha.
       
   END.  /*  Fim do DO WHILE TRUE  */

   ASSIGN tel_nmusuari = aux_dslinha.

   DISPLAY tel_nmusuari
           WITH FRAME f_param.
           
   INPUT STREAM str_1 CLOSE.

   /* remove o arquivo QUOTER */ 
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   /* volta o nome para o arquivo UNIX e o remove */
   ASSIGN aux_nmarquiv = SUBSTRING(aux_nmarquiv,1,LENGTH(aux_nmarquiv) - 2).
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   /* volta o nome para o arquivo original e remove */
   ASSIGN aux_nmarquiv = SUBSTRING(aux_nmarquiv,1,LENGTH(aux_nmarquiv) - 3).
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   HIDE MESSAGE NO-PAUSE.
 
END PROCEDURE.

/* .......................................................................... */

