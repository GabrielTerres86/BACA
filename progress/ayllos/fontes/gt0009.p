/* .............................................................................

   Programa: fontes/gt0009.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Outubro/2004.                       Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela GT0009.

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
             
               26/01/2006 - Unificacao dos Bancos. Adicionado NO-UNDO para a 
                            TEMP-TABLE w-telas. - SQLWorks - Fernando.
                            
               10/03/2006 - Atualizar a variavel que guarda se o operador 
                            viu a AJUDA (Evandro).
                            
               18/08/2006 - Implementada opcao de Pesquisa (Diego).
               
               23/08/2006 - Alterado nro de linhas de 800 para 1000 (Evandro).

                          - Alterado para exibir a AJUDA de acordo com a rotina
                            da tela (Evandro).
                            
               01/09/2006 - Correcao da impressao das versoes (Evandro).
               
               13/09/2006 - Excluidas opcoes "TAB" (Diego).
               
               21/09/2006 - Alterado o salvamento das versoes (Evandro).
               
               04/10/2006 - Modificado o evento sair (Evandro).
               
               09/07/2007 - Melhorada a mensagem quando estiver tentando
                            alterar uma ajuda a partir de uma cooperativa
                            diferente da 3-CECRED (Evandro).
                            
               03/06/2009 - Alteracao CDOPERAD (Kbase).
               
               04/06/2009 - Ajustado problema com quebra de pagina na procedure
                            imprime_help.
                            Ajustado problema com FRAME f_aguarde que ficava
                            na tela apos cancelamendo da impressao (Fernando).

               16/04/2012 - Fonte substituido por gt0009p.p (Tiago).
               
               29/05/2012 - Ajustes para Oracle (Evandro).

               18/10/2012 - Ajustes para a nova estrutura gnchopa (Gabriel).
               
               05/12/2013 - Inclusao de VALIDATE gnchelp e gnchope (Carlos)
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
.............................................................................*/
{ includes/var_online.i }

DEF STREAM str_1. 

DEF     VAR tel_nmdatela    AS CHAR     FORMAT "x(6)"                  NO-UNDO.
DEF     VAR tel_nmrotina    AS CHAR     FORMAT "x(25)"                 NO-UNDO.
DEF     VAR tel_dsdohelp    AS CHAR                                    NO-UNDO.
DEF     VAR tel_nrversao    AS INT      FORMAT "zz9"                   NO-UNDO.
DEF     VAR tel_dtlibera    AS DATE     FORMAT "99/99/9999"            NO-UNDO.
DEF     VAR tel_altera      AS CHAR     EXTENT 2   FORMAT "x(13)"
                            INIT ["Atual",
                                  "Em desenvolv."]         NO-UNDO.

DEF     VAR aux_contador    AS INT                                     NO-UNDO.
DEF     VAR aux_confirma    AS CHAR     FORMAT "!"                     NO-UNDO.
DEF     VAR aux_nmarqimp    AS CHAR                                    NO-UNDO.
DEF     VAR aux_tldatela    AS CHAR                                    NO-UNDO.
DEF     VAR aux_cabdatel    AS CHAR     FORMAT "x(80)"                 NO-UNDO.
DEF     VAR aux_pesquisa    AS CHAR     FORMAT "x(30)"                 NO-UNDO.
DEF     VAR aux_lsrotina    AS CHAR                                    NO-UNDO.
DEF     VAR aux_nrindrot    AS INT                                     NO-UNDO.
DEF     VAR aux_dsdohelp    AS CHAR                                    NO-UNDO.

/* somente para imprimir dsdohelp no arquivo */
DEF     VAR edi_relatorio   AS CHAR    VIEW-AS EDITOR SIZE 74 BY 1 PFCOLOR 0.

DEF     BUTTON btn-salvar    LABEL "Salvar".
DEF     BUTTON btn-sair      LABEL "Sair".
DEF     BUTTON btn-sairc     LABEL "Sair".
DEF     BUTTON btn-imprimir  LABEL "Imprimir".
DEF     BUTTON btn-pesquisar LABEL "Pesquisar".

/* tabela temporaria para o browse */
DEF TEMP-TABLE w_telas                                                 NO-UNDO
    FIELD tldatela  AS CHAR FORMAT "x(40)" 
    FIELD nmrotina  AS CHAR FORMAT "x(25)"
    FIELD nmoperad  LIKE crapope.nmoperad
    FIELD nrversao  LIKE gnchelp.nrversao
    FIELD dtlibera  AS CHAR FORMAT "x(08)".
    
DEF QUERY q_telas FOR w_telas.
                      
DEF BROWSE b_telas QUERY q_telas                      
    DISPLAY w_telas.tldatela   LABEL "Tela"         FORMAT "x(15)"
            w_telas.nmrotina   LABEL "Rotina"       FORMAT "x(25)"
            w_telas.nmoperad   LABEL "Por"          FORMAT "x(18)"
            w_telas.nrversao   LABEL "Ver."         FORMAT "zzz9"
            w_telas.dtlibera   LABEL "Liberada"  
            WITH 10 DOWN CENTERED NO-LABELS OVERLAY NO-BOX. 

/* variaveis para impressao */
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nrmodulo     AS INT     FORMAT "9"                NO-UNDO.
DEF        VAR rel_nmmodulo     AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
DEF        VAR rel_nmmesref AS CHAR    FORMAT "x(014)"               NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

FORM  SKIP(1)
      glb_cddopcao     AT  3 LABEL "Opcao"    AUTO-RETURN
                             HELP "Informe a opcao desejada (A, C, R, V)"
                             VALIDATE(CAN-DO("A,C,R,V",glb_cddopcao),
                                      "014 - Opcao errada.")
      tel_nmdatela     AT 13 LABEL "Tela  "
                             HELP "Entre com o nome da tela desejada"
                             
      "-"              AT 28
      craptel.tldatela AT 30 NO-LABEL         FORMAT "x(12)"
      tel_nmrotina     AT 45 LABEL "Rotina"   FORMAT "x(25)"
                HELP "Use as setas de direcao para escolher a rotina desejada."
      WITH ROW 4 SIZE 80 BY 18 SIDE-LABELS OVERLAY TITLE glb_tldatela 
           FRAME f_cad.
           
FORM  tel_nrversao     AT 15 LABEL "Versao"
      gnchelp.dtmvtolt AT 32 LABEL "Data"
      tel_dtlibera     AT 56 LABEL "Liberar em"
                             HELP "Entre com a data de liberacao da versao"
                             VALIDATE(INPUT tel_dtlibera >= glb_dtmvtopr,
                                      "013 - Data errada.")
      SKIP
      tel_dsdohelp     AT  2 NO-LABEL    VIEW-AS EDITOR NO-BOX INNER-LINES 10
                                         INNER-CHARS 74 BUFFER-LINES 1000
                                         SCROLLBAR-VERTICAL PFCOLOR 1
                  HELP "Use SETAS / PAGE UP / PAGE DOWN para navegar"
      SKIP
      btn-pesquisar AT 14 HELP "Pressione ENTER para efetuar a pesquisa."
      btn-salvar    AT 35 HELP "Pressione ENTER para SALVAR as alteracoes."
      btn-sair      AT 54 
                    HELP "Pressione ENTER para SAIR/DESCARTAR as alteracoes."
      WITH ROW 7 CENTERED SIZE 78 BY 14 SIDE-LABELS OVERLAY NO-BOX NO-LABELS 
           FRAME f_help.
      
FORM SKIP(1)
     tel_dsimprim AT 10
     tel_dscancel TO 30 
     SKIP(1)
     WITH ROW 12 CENTERED OVERLAY NO-LABELS WIDTH 40 
          TITLE " Impressao da AJUDA "  FRAME f_imprime.

DEF FRAME fra_relatorio
    edi_relatorio HELP "Pressione <F4> ou <END> para finalizar"
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.    
    
FORM "Aguarde... Imprimindo AJUDA..."
     WITH ROW 13 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM  tel_nrversao     AT  2 LABEL "Versao"
      gnchelp.dtmvtolt AT 15 LABEL "Ult.Alter."
      tel_dtlibera     AT 39 LABEL "Lib."
      gnchelp.nmoperad AT 57 LABEL "Por"   FORMAT "x(16)" 
      SKIP
      tel_dsdohelp AT  2 NO-LABEL    VIEW-AS EDITOR NO-BOX INNER-LINES 10
                                     INNER-CHARS 74 BUFFER-LINES 1000
                                     SCROLLBAR-VERTICAL  PFCOLOR 0
                 HELP "Use SETAS / PAGE UP / PAGE DOWN para navegar"
      SKIP
      btn-pesquisar AT 14 
                    HELP "Pressione ENTER para efetuar a pesquisa."
      btn-imprimir AT 35
                   HELP "Pressione ENTER para IMPRIMIR."
      btn-sairc    AT 54 
                   HELP "Pressione ENTER para SAIR/DESCARTAR as alteracoes."
      WITH ROW 7 CENTERED SIZE 78 BY 14 SIDE-LABELS OVERLAY NO-BOX NO-LABELS 
           USE-TEXT FRAME f_consulta.

FORM "Versao:"      AT  3
     tel_altera[2]  AT 11  HELP "Pressione ENTER para selecionar"
     SKIP
     tel_altera[1]  AT 11  HELP "Pressione ENTER para selecionar"
     WITH NO-BOX NO-LABELS SIDE-LABELS COLUMN 14 ROW 8 OVERLAY FRAME f_versao.

FORM SKIP(1)
     b_telas  HELP "Use as SETAS para navegar / <F4> ou <END> para sair"
     WITH ROW 6 CENTERED OVERLAY TITLE " Telas com AJUDA ja cadastrada " 
          FRAME f_telas.

FORM aux_pesquisa  HELP "Informa a palavra ou parte dela."
     WITH ROW 12 COLUMN 25 NO-LABEL WITH OVERLAY WIDTH 32 FRAME f_pesquisa.
     

ON CHOOSE OF btn-salvar IN FRAME f_help DO:

   IF  AVAIL gnchelp  THEN
       aux_dsdohelp = gnchelp.dsdohelp.
   ELSE
       aux_dsdohelp = "".

   IF   ((AVAIL gnchelp AND 
          aux_dsdohelp = INPUT FRAME f_help tel_dsdohelp)  AND
         (AVAIL gnchelp AND 
          gnchelp.dtlibera = INPUT FRAME f_help tel_dtlibera)) OR
         (NOT AVAIL gnchelp AND INPUT FRAME f_help tel_dsdohelp = " ")  THEN
        DO:
            MESSAGE "Nao houveram alteracoes - a versao nao foi salva!".
            PAUSE 2 NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE.
            NEXT.
        END.
   
   IF   NOT AVAILABLE gnchelp              OR
        gnchelp.dtlibera <= glb_dtmvtolt   THEN
        DO:
            CREATE gnchelp.
            CREATE gnchopa.
        END.
   ELSE
        DO: 
            FIND CURRENT gnchelp EXCLUSIVE-LOCK NO-ERROR.

            FIND gnchopa WHERE gnchopa.nmdatela = gnchelp.nmdatela   AND
                               gnchopa.nmrotina = gnchelp.nmrotina   AND
                               gnchopa.nrversao = gnchelp.nrversao
                               EXCLUSIVE-LOCK NO-ERROR.
                               
        END.

   FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND 
                      crapope.cdoperad = glb_cdoperad NO-LOCK NO-ERROR.
   
   ASSIGN gnchelp.nmdatela = tel_nmdatela
          gnchelp.nmrotina = tel_nmrotina
          gnchelp.nrversao = tel_nrversao
          gnchelp.dtmvtolt = glb_dtmvtolt
          gnchelp.cdoperad = glb_cdoperad
          gnchelp.nmoperad = crapope.nmoperad
          gnchelp.dsdohelp = INPUT FRAME f_help tel_dsdohelp
          gnchelp.dtlibera = INPUT FRAME f_help tel_dtlibera.

   VALIDATE gnchelp.

   ASSIGN gnchopa.nmdatela = gnchelp.nmdatela
          gnchopa.nmrotina = gnchelp.nmrotina
          gnchopa.nrversao = gnchelp.nrversao
          gnchopa.lsopeavi = "".

   VALIDATE gnchopa.
   
   /* verifica se ha mais de 3 versoes e se tiver apaga a mais velha */
   aux_contador = 0.
   FOR EACH gnchelp WHERE gnchelp.nmdatela = tel_nmdatela   AND
                          gnchelp.nmrotina = tel_nmrotina   NO-LOCK:
       aux_contador = aux_contador + 1.
   END.
   
   IF   aux_contador > 3   THEN
        DO:
            FIND FIRST gnchelp WHERE gnchelp.nmdatela = tel_nmdatela   AND
                                     gnchelp.nmrotina = tel_nmrotina            
                                     EXCLUSIVE-LOCK NO-ERROR.
            DELETE gnchelp.
        END.
        
   FIND LAST gnchelp WHERE gnchelp.nmdatela = tel_nmdatela   AND
                           gnchelp.nmrotina = tel_nmrotina   AND
                           gnchelp.nrversao = tel_nrversao   NO-LOCK NO-ERROR.
                           
   MESSAGE "Versao salva com sucesso!".
   PAUSE 2 NO-MESSAGE.
   HIDE MESSAGE NO-PAUSE.
END.

ON CHOOSE OF btn-sairc DO:
   /* entra aqui se foi outra tela que chamou - para voltar a tela anterior */
   IF   glb_nmdatela <> "GT0009"   THEN
        DO:
            glb_tldatela = aux_tldatela.
            HIDE FRAME f_cad.
            HIDE FRAME f_help.
            HIDE FRAME f_consulta.
            HIDE FRAME f_imprime.
            APPLY "END-ERROR".
        END.
   ELSE
        APPLY "END-ERROR".
END. 

ON CHOOSE OF btn-imprimir DO:
   RUN imprime_help.
END.

ON CHOOSE OF btn-sair DO:

   /* reposiciona no registro */
   FIND LAST gnchelp WHERE gnchelp.nmdatela = tel_nmdatela   AND
                           gnchelp.nmrotina = tel_nmrotina   AND
                           gnchelp.nrversao = tel_nrversao   NO-LOCK NO-ERROR.

   /* entra aqui se foi outra tela que chamou - para voltar a tela anterior */
   IF   glb_nmdatela <> "GT0009"   THEN
        DO:
            glb_tldatela = aux_tldatela.
            HIDE FRAME f_cad.
            HIDE FRAME f_help.
            HIDE FRAME f_consulta.
            HIDE FRAME f_imprime.
            APPLY "END-ERROR".
        END.
   
   IF   glb_cddopcao = "A"   THEN
        DO:
           IF  AVAIL gnchelp  THEN
               aux_dsdohelp = gnchelp.dsdohelp.
           ELSE
               aux_dsdohelp = "".
       
           IF  (AVAIL gnchelp   AND
                aux_dsdohelp <> INPUT FRAME f_help tel_dsdohelp) OR
               (NOT AVAIL gnchelp AND
                INPUT FRAME f_help tel_dsdohelp <> " ")  THEN
                DO:
                    aux_confirma = "N".

                    MESSAGE COLOR NORMAL 
                            "Houveram alteracoes - Deseja abandona-las? (S/N)" 
                            UPDATE aux_confirma.
                    IF   aux_confirma = "S"   THEN
                         DO:
                             glb_cddopcao = "C".
                             APPLY "END-ERROR".
                         END.
                    ELSE
                         RETURN NO-APPLY.
                END.
        END.
   
   APPLY "END-ERROR".
END.    

ON CHOOSE OF btn-pesquisar IN FRAME f_help DO: 

   DO WHILE TRUE:

      UPDATE aux_pesquisa WITH FRAME f_pesquisa.

      HIDE FRAME f_pesquisa NO-PAUSE.

      IF   tel_dsdohelp  MATCHES "*" + aux_pesquisa + "*"  THEN
           tel_dsdohelp:SEARCH(aux_pesquisa,16).
      ELSE
           DO:
               MESSAGE "Expressao nao encontrada".
               NEXT.
           END.
    
      LEAVE.    
   END.
           
   APPLY "BACK-TAB". 
   RETURN NO-APPLY.

END.

ON CHOOSE OF btn-pesquisar IN FRAME f_consulta DO:

   DO WHILE TRUE:

      UPDATE aux_pesquisa WITH FRAME f_pesquisa.

      HIDE FRAME f_pesquisa NO-PAUSE.

      IF   tel_dsdohelp  MATCHES "*" + aux_pesquisa + "*"  THEN
           tel_dsdohelp:SEARCH(aux_pesquisa,16).
      ELSE
           DO:
               MESSAGE "Expressao nao encontrada".
               NEXT.
           END.
      
      LEAVE.    
   END.
   
   APPLY "BACK-TAB". 
   RETURN NO-APPLY.
    
END.

ON END-ERROR OF tel_dsdohelp IN FRAME f_consulta 
   DO:
       NEXT-PROMPT btn-pesquisar WITH FRAME f_consulta.
       RETURN NO-APPLY.
   END.
       
ON END-ERROR OF tel_dsdohelp IN FRAME f_help 
   DO:
       NEXT-PROMPT btn-pesquisar WITH FRAME f_help.
       RETURN NO-APPLY.
   END.

ON "GO" OF INPUT FRAME f_consulta tel_dsdohelp  DO:
   IF   glb_nmdatela <> "GT0009"   THEN
        APPLY "CHOOSE" TO INPUT FRAME f_consulta btn-sairc.
END.

ON RETURN OF b_telas DO:

   IF   NOT AVAILABLE w_telas   THEN
        APPLY "END-ERROR".

   ASSIGN tel_nmdatela = SUBSTRING(w_telas.tldatela,1,6)
          tel_nmrotina = w_telas.nmrotina
          tel_nrversao = w_telas.nrversao
          glb_cddopcao = "V".
          
   FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper   AND
                            craptel.nmdatela = tel_nmdatela   AND
                            craptel.nmrotina = tel_nmrotina   NO-LOCK NO-ERROR.
          
   IF   NOT AVAILABLE craptel   THEN
        DO:
            glb_cdcritic = 322.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
              
   FIND LAST gnchelp WHERE gnchelp.nmdatela = tel_nmdatela   AND
                           gnchelp.nmrotina = tel_nmrotina   AND
                           gnchelp.nrversao = tel_nrversao   NO-LOCK NO-ERROR.
 
   DISPLAY glb_cddopcao  tel_nmdatela  tel_nmrotina  craptel.tldatela 
           WITH FRAME f_cad.
   PAUSE 0.                         
               
   RUN consulta_help.
   
END.

ON LEAVE OF tel_nmdatela IN FRAME f_cad DO:

   IF   CAN-FIND(FIRST craptel WHERE craptel.cdcooper = glb_cdcooper        AND
                                     craptel.nmdatela = INPUT tel_nmdatela  AND
                                     craptel.nmrotina = "")
        THEN
        DO:
            /* Mostra o nome da tela */
            FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper        AND
                                     craptel.nmdatela = INPUT tel_nmdatela  AND
                                     craptel.nmrotina = ""
                                     NO-LOCK.
                                     
            tel_nmdatela = CAPS(INPUT tel_nmdatela).
            
            DISPLAY tel_nmdatela craptel.tldatela WITH FRAME f_cad.
            
            /* Carrega a lista de rotinas da tela */
            ASSIGN aux_lsrotina = ""
                   aux_nrindrot = 0.
                   
            FOR EACH craptel WHERE craptel.cdcooper = glb_cdcooper        AND
                                   craptel.nmdatela = INPUT tel_nmdatela  
                                   NO-LOCK BY craptel.nmrotina:

                ASSIGN aux_lsrotina = aux_lsrotina + craptel.nmrotina + ","
                       aux_nrindrot = aux_nrindrot + 1.
            END.
            
            /* Tira a ultima "," */
            aux_lsrotina = SUBSTRING(aux_lsrotina,1,LENGTH(aux_lsrotina) - 1).
            
        END.
   ELSE
        ASSIGN aux_lsrotina = ""
               aux_nrindrot = 1.
END.


DO WHILE TRUE:

   ASSIGN glb_cddopcao = "C"
          tel_nrversao = 1
          tel_dtlibera = glb_dtmvtopr
          tel_dsdohelp = "".
                        
   CLEAR FRAME f_cad.
   CLEAR FRAME f_help.          

   /* entra se usuario pressionou F2 na tela GT0009 */
   IF   KEYFUNCTION(LASTKEY) = "HELP"   AND
        glb_nmdatela = "GT0009"         THEN
        DO:
            RETURN.
        END.
   
   /* tratamento diferenciado para AJUDA na tela IDENTI */
   IF   glb_nmdatela = ""   THEN
        DO:
            IF   glb_tldatela MATCHES "*IDENTI*"   THEN
                 glb_nmdatela = "IDENTI".
            ELSE
                 RETURN.
        END.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      RUN fontes/inicia.p.

      /* se foi outra tela que chamou - "abrir" ajuda da tela que chamou */
      IF   glb_nmdatela <> "GT0009"   THEN
           DO:

               /* para pegar o titulo da tela GT0009*/
               FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper AND
                                        craptel.nmdatela = "GT0009" 
                                        NO-LOCK NO-ERROR.
               
               ASSIGN tel_nmdatela = glb_nmdatela
                      tel_nmrotina = glb_nmrotina
                                    /* guarda o titulo da tela que chamou*/
                      aux_tldatela = glb_tldatela
                      glb_tldatela = craptel.tldatela + " (Usuario: " +
                                     ENTRY(1,glb_nmoperad," ") + " - Imp: " +
                                     
                                     IF   glb_nmdafila = "" THEN
                                          "Escrava )"
                                     ELSE 
                                          TRIM(glb_nmdafila) + ") ".

               FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper AND
                                        craptel.nmdatela = tel_nmdatela AND
                                        craptel.nmrotina = tel_nmrotina
                                        NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craptel   THEN
                    DO:
                        glb_cdcritic = 322.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                    
               /* Pega o nome da tela principal */
               IF   tel_nmrotina <> ""   THEN
                    FIND FIRST craptel WHERE
                                       craptel.cdcooper = glb_cdcooper AND
                                       craptel.nmdatela = tel_nmdatela 
                                       NO-LOCK NO-ERROR.
              
               FIND LAST gnchelp WHERE gnchelp.nmdatela = tel_nmdatela   AND
                                       gnchelp.nmrotina = tel_nmrotina   AND
                                       gnchelp.dtlibera <= glb_dtmvtolt
                                       NO-LOCK NO-ERROR.
                                       
               /* O operador viu essa versao */
               glb_opvihelp = YES.
                     
               DISPLAY glb_cddopcao  tel_nmdatela  
                       tel_nmrotina  craptel.tldatela 
                       WITH FRAME f_cad.
               PAUSE 0.
               
               /* Posiciona no registro da rotina */
               FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper AND
                                        craptel.nmdatela = tel_nmdatela AND
                                        craptel.nmrotina = tel_nmrotina
                                        NO-LOCK NO-ERROR.
               
               RUN consulta_help.
               
               HIDE FRAME f_cad.
               HIDE FRAME f_help.
               HIDE FRAME f_consulta.
               HIDE FRAME f_imprime.
               
               RETURN.

           END.
      ELSE         /* se nao foi outra tela que chamou*/
           DO:
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            

                 ASSIGN glb_cddopcao = "C"
                        tel_nrversao = 1
                        tel_dtlibera = glb_dtmvtopr
                        tel_dsdohelp = ""
                        aux_contador = 1
                        tel_nmrotina = "".
                        
                 CLEAR FRAME f_cad.
                 CLEAR FRAME f_help.          
    
                 UPDATE glb_cddopcao tel_nmdatela tel_nmrotina WITH FRAME f_cad
                 
                 EDITING:
                    
                    DO WHILE TRUE:
                       READKEY PAUSE 1.

                       IF   FRAME-FIELD = "glb_cddopcao"   AND
                            KEYFUNCTION(LASTKEY) = "V"     THEN
                            DO: 
                                APPLY LASTKEY.
                                RUN mostra_telas.
                                
                                HIDE FRAME f_telas.
                                ASSIGN tel_nmdatela = ""
                                       glb_cddopcao = "C".
          
                                CLEAR FRAME f_cad.
                                DISPLAY glb_cddopcao  tel_nmdatela  
                                        WITH FRAME f_cad.
                                PAUSE 0.                         
                            END.
                       ELSE
                       IF   FRAME-FIELD = "tel_nmrotina"   THEN
                            DO: 
                                IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"   THEN
                                     DO:
                                         IF   aux_contador = 1   THEN
                                              aux_contador = aux_nrindrot.
                                         ELSE 
                                              aux_contador = aux_contador - 1.
                                     END.

                                IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  THEN
                                     DO:
                                         IF   aux_contador = aux_nrindrot  THEN
                                              aux_contador = 1.
                                         ELSE 
                                              aux_contador = aux_contador + 1.
                                     END.
                                     
                                tel_nmrotina = ENTRY(aux_contador,
                                                     aux_lsrotina).

                                DISPLAY tel_nmrotina WITH FRAME f_cad.
                                PAUSE 0.
                                
                                IF   KEYFUNCTION(LASTKEY) = "RETURN"    OR
                                     KEYFUNCTION(LASTKEY) = "BACK-TAB"  OR
                                     KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                     KEYFUNCTION(LASTKEY) = "F1"  THEN
                                     APPLY LAST-KEY.
                            END.
                       ELSE
                            APPLY LASTKEY.
                        
                       LEAVE.
                    END.  /*  Fim do DO WHILE TRUE  */
                 END.  /*  Fim do EDITING  */

                 LEAVE.
              
              END.

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*F4 OU FIM*/
                   DO:
                       RUN fontes/novatela.p.
                       IF   glb_nmdatela <> "GT0009"   THEN
                            DO:
                                HIDE FRAME f_cad.
                                HIDE FRAME f_help.
                                HIDE FRAME f_consulta.
                                HIDE FRAME f_imprime.
                                RETURN.
                            END.
                       ELSE
                            NEXT.
                   END.
                
              ASSIGN tel_nmdatela = CAPS(tel_nmdatela).
              
              FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper   AND
                                       craptel.nmdatela = tel_nmdatela   AND
                                       craptel.nmrotina = tel_nmrotina
                                       NO-LOCK NO-ERROR.
          
              IF   NOT AVAILABLE craptel   THEN
                   DO:
                       glb_cdcritic = 322.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       NEXT.
                   END.
              
              IF   glb_cddopcao = "C"   THEN
                   DO:
                      FIND LAST gnchelp WHERE 
                                gnchelp.nmdatela = tel_nmdatela   AND
                                gnchelp.nmrotina = tel_nmrotina   AND
                                gnchelp.dtlibera <= glb_dtmvtolt 
                                NO-LOCK NO-ERROR.
                                
                      RUN consulta_help.
                   END.
              ELSE
              IF   glb_cddopcao = "A"   THEN
                   DO:
                       { includes/acesso.i }
                       
                       FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                                          NO-LOCK NO-ERROR.
                       
                       IF   crapcop.cdcooper <> 3   THEN
                            DO:
                                glb_cdcritic = 794.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                MESSAGE "Opcao valida somente para a"
                                        "cooperativa 3-CECRED".
                                glb_cdcritic = 0.
                                RETURN.
                            END.
                            
                       /* se tiver uma versao em desenvolvimento*/
                       IF   CAN-FIND(gnchelp WHERE 
                                     gnchelp.nmdatela = tel_nmdatela   AND
                                     gnchelp.nmrotina = tel_nmrotina   AND
                                     gnchelp.dtlibera > glb_dtmvtolt)  THEN
                          DO:                   

                              IF  CAN-FIND(LAST gnchelp WHERE 
                                  gnchelp.nmdatela = tel_nmdatela    AND
                                  gnchelp.nmrotina = tel_nmrotina    AND
                                  gnchelp.dtlibera <= glb_dtmvtolt)  THEN
                                  DO:
                                      DISPLAY tel_altera WITH FRAME f_versao.
                                      CHOOSE FIELD tel_altera 
                                                   WITH FRAME f_versao.
                                  END.
                              ELSE
                                  DO:       
                                     DISPLAY tel_altera[2] WITH FRAME f_versao.
                                     HIDE tel_altera[1] IN FRAME f_versao.     
                                     CHOOSE FIELD 
                                            tel_altera[2] WITH FRAME f_versao.
                                  END.

                              /* versao desenvolvimento */  
                              IF   FRAME-VALUE = tel_altera[2]   THEN
                                   DO:
                                       FIND LAST gnchelp WHERE 
                                                 gnchelp.nmdatela =
                                                         tel_nmdatela  AND
                                                 gnchelp.nmrotina =
                                                         tel_nmrotina  AND
                                                 gnchelp.dtlibera >
                                                         glb_dtmvtolt
                                                 NO-LOCK NO-ERROR.
                                        
                                       IF   AVAILABLE gnchelp   THEN
                                            ASSIGN tel_nrversao =
                                                          gnchelp.nrversao
                                                   tel_dsdohelp =
                                                          gnchelp.dsdohelp
                                                   tel_dtlibera =
                                                          gnchelp.dtlibera.
                                   END.
                              ELSE

                              /* versao atual */
                              IF   FRAME-VALUE = tel_altera[1]   THEN
                                   DO:

                                       aux_confirma = "S".
                                       
                                       MESSAGE COLOR NORMAL "Ha uma versao em"
                                       "desenvolvimento que sera eliminada,"
                                       "imprimi-la? (S/N)" UPDATE aux_confirma.
                                       
                                       IF   aux_confirma = "S"   THEN
                                            DO:
                                               FIND LAST gnchelp WHERE 
                                                     gnchelp.nmdatela =
                                                             tel_nmdatela  AND
                                                     gnchelp.nmrotina =
                                                             tel_nmrotina  AND
                                                     gnchelp.dtlibera >
                                                             glb_dtmvtolt
                                                             NO-LOCK NO-ERROR.

                                                RUN imprime_help.
                                            END.
                                       
                                       /* para pegar o conteudo a versao atual*/
                                       FIND LAST gnchelp WHERE 
                                                 gnchelp.nmdatela =
                                                         tel_nmdatela  AND
                                                 gnchelp.nmrotina =
                                                         tel_nmrotina  AND
                                                 gnchelp.dtlibera <=
                                                         glb_dtmvtolt
                                                 NO-LOCK NO-ERROR.

                                       IF   AVAILABLE gnchelp   THEN
                                            ASSIGN tel_dsdohelp =
                                                         gnchelp.dsdohelp.
                                                           
                                        /* para editar a nova versao */
                                        FIND LAST gnchelp WHERE 
                                                  gnchelp.nmdatela =
                                                          tel_nmdatela  AND
                                                  gnchelp.nmrotina =
                                                          tel_nmrotina  AND
                                                  gnchelp.dtlibera >
                                                          glb_dtmvtolt
                                                  NO-LOCK NO-ERROR.
                                       
                                        IF   AVAILABLE gnchelp   THEN
                                             ASSIGN tel_nrversao =
                                                           gnchelp.nrversao
                                                    tel_dtlibera =
                                                           glb_dtmvtopr.       
                                   END.
                          END.
                       ELSE   /* se nao tiver versao de desenv. */
                          DO:
                              FIND LAST gnchelp WHERE 
                                        gnchelp.nmdatela = tel_nmdatela  AND
                                        gnchelp.nmrotina = tel_nmrotina  AND
                                        gnchelp.dtlibera <= glb_dtmvtolt
                                        NO-LOCK NO-ERROR.

                              IF   AVAILABLE gnchelp   THEN
                                   ASSIGN tel_nrversao = gnchelp.nrversao + 1
                                          tel_dsdohelp = gnchelp.dsdohelp.
                              ELSE
                                   tel_dsdohelp = "".
                                          
                          END.
                            
                       HIDE FRAME f_consulta.
                   
                       DISPLAY tel_nrversao tel_dsdohelp tel_dtlibera
                               WITH FRAME f_help.

                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE tel_dtlibera tel_dsdohelp btn-pesquisar
                                    btn-salvar btn-sair WITH FRAME f_help.
                          END.
                          
                          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    
                               DO:
                                   APPLY "CHOOSE" TO INPUT 
                                         FRAME f_help btn-sair.
   
                                   IF   aux_confirma = "N"   THEN
                                        DO:
                                            tel_dsdohelp = INPUT FRAME f_help
                                                           tel_dsdohelp.
                                            NEXT.
                                        END.
                               END.
                          
                          LEAVE.
                       
                       END.
                   END.
              ELSE
              IF   glb_cddopcao = "R"   THEN
                   DO:
                       /* se tiver uma versao em desenvolvimento*/
                       IF   CAN-FIND(gnchelp WHERE 
                                     gnchelp.nmdatela = tel_nmdatela   AND
                                     gnchelp.nmrotina = tel_nmrotina   AND
                                     gnchelp.dtlibera > glb_dtmvtolt)  THEN
                          DO:   
                             IF  CAN-FIND(LAST gnchelp WHERE 
                                  gnchelp.nmdatela = tel_nmdatela    AND
                                  gnchelp.nmrotina = tel_nmrotina    AND
                                  gnchelp.dtlibera <= glb_dtmvtolt)  THEN
                                  DO:
                                     DISPLAY tel_altera WITH FRAME f_versao.
                                     CHOOSE FIELD tel_altera 
                                                  WITH FRAME f_versao.
                                  END.
                              ELSE
                                  DO:       
                                     DISPLAY tel_altera[2] WITH FRAME f_versao.
                                     HIDE tel_altera[1] IN FRAME f_versao.
                                     CHOOSE FIELD 
                                             tel_altera[2] WITH FRAME f_versao.
                                  END.

                              /* versao desenvolvimento */  
                              IF   FRAME-VALUE = tel_altera[2]   THEN
                                   DO:
                                        FIND LAST gnchelp WHERE 
                                                  gnchelp.nmdatela =
                                                          tel_nmdatela  AND
                                                  gnchelp.nmrotina =
                                                          tel_nmrotina  AND
                                                  gnchelp.dtlibera >
                                                          glb_dtmvtolt
                                                  NO-LOCK NO-ERROR.
                                   END.
                              ELSE
                                   DO:
                                      /* versao atual */
                                      IF   FRAME-VALUE = tel_altera[1]   THEN
                                           DO:
                                               FIND LAST gnchelp WHERE 
                                                         gnchelp.nmdatela =
                                                               tel_nmdatela AND
                                                         gnchelp.nmrotina =
                                                               tel_nmrotina AND
                                                         gnchelp.dtlibera <=
                                                               glb_dtmvtolt
                                                               NO-LOCK NO-ERROR.
                                           END.
                                   END.
                          END.
                       ELSE    /* se nao tiver versao de desenvolvimento */
                            DO:
                                FIND LAST gnchelp WHERE 
                                                 gnchelp.nmdatela =
                                                         tel_nmdatela  AND
                                                 gnchelp.nmrotina =
                                                         tel_nmrotina  AND
                                                 gnchelp.dtlibera <=
                                                         glb_dtmvtolt
                                                         NO-LOCK NO-ERROR.
                            END.
                      
                      IF   NOT AVAILABLE gnchelp   THEN
                           DO:
                              MESSAGE "Ajuda nao cadastrada".
                              PAUSE.
                              APPLY "CHOOSE" TO INPUT FRAME 
                                                      f_consulta btn-sairc.
                              RETURN.
                            END.
                      
                      RUN imprime_help.
                      NEXT.
                   END.
           END.
   END.                    
   
END.


PROCEDURE imprime_help.

   DEF BUFFER crabtel FOR craptel.
   
   PAUSE 0.
   DISPLAY      tel_dsimprim tel_dscancel  WITH FRAME f_imprime.
   CHOOSE FIELD tel_dsimprim tel_dscancel  WITH FRAME f_imprime.

   IF   FRAME-VALUE = tel_dsimprim   THEN
        DO:
            VIEW FRAME f_aguarde.
            PAUSE 3 NO-MESSAGE.
        END.
   ELSE
        RETURN.
   
   /* Pergunta se deseja imprimir todas as rotinas */
   IF   tel_nmrotina = ""                                                AND
        CAN-FIND(FIRST gnchelp WHERE gnchelp.nmdatela  = tel_nmdatela    AND
                                     gnchelp.nmrotina <> ""              AND
                                     gnchelp.dtlibera <= glb_dtmvtolt)   THEN 
        DO:
            MESSAGE "Deseja imprimir a AJUDA de TODAS as rotinas da tela?"
                    UPDATE aux_confirma.
                    
            IF   aux_confirma <> "S"   THEN
                 aux_confirma = "N".
        END.
   ELSE
        aux_confirma = "N".
   
   INPUT THROUGH basename `tty` NO-ECHO.
   SET aux_nmendter WITH FRAME f_terminal.
   INPUT CLOSE.       
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.

   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
   ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
   
   /** SIZE 79 para ajustar problema com quebra de pagina **/
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 79.
  
   /* Nome da tela - principal */
   FIND crabtel WHERE crabtel.cdcooper = craptel.cdcooper   AND
                      crabtel.nmdatela = craptel.nmdatela   AND
                      crabtel.nmrotina = ""                 NO-LOCK NO-ERROR.
                      
                      
   /* Impressao de todas as rotinas */
   IF   aux_confirma = "S"   THEN
        DO:
            FOR EACH craptel WHERE craptel.cdcooper = crabtel.cdcooper  AND
                                   craptel.nmdatela = crabtel.nmdatela  AND
                                  (craptel.nmrotina = tel_nmrotina      OR
                                   aux_confirma     = "S")              
                                   NO-LOCK:
                   
                /* Versoes liberadas */
                FIND LAST gnchelp WHERE gnchelp.nmdatela  = craptel.nmdatela
                                    AND gnchelp.nmrotina  = craptel.nmrotina
                                    AND gnchelp.dtlibera <= glb_dtmvtolt 
                                    NO-LOCK NO-ERROR.
                            
                IF   NOT AVAILABLE gnchelp   THEN
                     NEXT.
   
                ASSIGN aux_cabdatel = 
                             STRING("\022\024\033\120\033\105","x(74)") +
                             STRING(" ","x(15)") +
                             "MANUAL DE AJUDA DAS TELAS - Sistema AYLLOS" +
                             STRING(" ","x(90)") +
                             "TELA  : " + STRING(tel_nmdatela,"x(6)") + " - " +
                             STRING(crabtel.tldatela,"x(57)") +
                             "ROTINA: " + STRING(craptel.nmrotina,"x(63)") +
                             "\033\106" + STRING(" ","x(75)") +
                             "Versao: " + STRING(gnchelp.nrversao,"zz9") + 
                             STRING(" ","x(22)") +
                             "Por: " +  STRING(gnchelp.cdoperad,"x(10)") + 
                             " - " + STRING(gnchelp.nmoperad,"x(29)") +
                             "Ultima alteracao : " + STRING(gnchelp.dtmvtolt,
                                                            "99/99/9999") +
                             STRING(" ","x(2)") +
                             "Data de Liberacao: " + 
                             STRING(gnchelp.dtlibera,"99/99/9999") +
                             STRING(" ","x(86)")
                    
                       aux_dsdohelp = gnchelp.dsdohelp.
                             
                ASSIGN edi_relatorio = aux_cabdatel + aux_dsdohelp.

                DISPLAY STREAM str_1  edi_relatorio  AT 5 
                        WITH FRAME fra_relatorio.
   
                PAGE STREAM str_1.
            END.

            OUTPUT STREAM str_1 CLOSE.
        END.
   ELSE
        /* Impressao da rotina atual */  
        DO:
            ASSIGN aux_cabdatel = 
                             STRING("\022\024\033\120\033\105","x(74)") +
                             STRING(" ","x(15)") +
                             "MANUAL DE AJUDA DAS TELAS - Sistema AYLLOS" +
                             STRING(" ","x(90)") +
                             "TELA  : " + STRING(tel_nmdatela,"x(6)") + " - " +
                             STRING(crabtel.tldatela,"x(57)") +
                             "ROTINA: " + STRING(craptel.nmrotina,"x(63)") +
                             "\033\106" + STRING(" ","x(75)") +
                             "Versao: " + STRING(gnchelp.nrversao,"zz9") + 
                             STRING(" ","x(22)") +
                             "Por: " +  STRING(gnchelp.cdoperad,"x(10)") + 
                             " - " + STRING(gnchelp.nmoperad,"x(29)") +
                             "Ultima alteracao : " + STRING(gnchelp.dtmvtolt,
                                                            "99/99/9999") +
                             STRING(" ","x(2)") +
                             "Data de Liberacao: " + 
                             STRING(gnchelp.dtlibera,"99/99/9999") +
                             STRING(" ","x(86)")
                
                   aux_dsdohelp = gnchelp.dsdohelp.
                             
            ASSIGN edi_relatorio = aux_cabdatel + aux_dsdohelp.
            
            DISPLAY STREAM str_1  edi_relatorio  AT 5 WITH FRAME fra_relatorio.
   
            OUTPUT STREAM str_1 CLOSE.
        END.
   
   HIDE FRAME f_aguarde NO-PAUSE.
   
   /* somente para poder executar a includes/impressao.i */
   FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

   { includes/impressao.i }

END PROCEDURE.

PROCEDURE consulta_help.

   IF   NOT AVAILABLE gnchelp   THEN
        DO:
            MESSAGE "Ajuda nao cadastrada".
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               PAUSE.
               LEAVE.
            END.
            APPLY "CHOOSE" TO INPUT FRAME f_consulta btn-sairc.
            RETURN.
        END.

   ASSIGN tel_nrversao = gnchelp.nrversao
          tel_dsdohelp = gnchelp.dsdohelp
          tel_dtlibera = gnchelp.dtlibera.

   HIDE FRAME f_help NO-PAUSE.
   
   DISPLAY tel_nrversao tel_dsdohelp gnchelp.dtmvtolt tel_dtlibera
           gnchelp.nmoperad  WITH FRAME f_consulta.

   /* para nao poder editar */
   ASSIGN tel_dsdohelp:READ-ONLY IN FRAME f_consulta = YES.

   UPDATE tel_dsdohelp btn-pesquisar btn-imprimir btn-sairc 
          WITH FRAME f_consulta.

END PROCEDURE.

PROCEDURE mostra_telas:
   
   DEF VAR aux_tldatela AS CHAR                         NO-UNDO.

   HIDE MESSAGE.
   
   /* limpar temp-table*/
   EMPTY TEMP-TABLE w_telas.

   /* telas liberadas */
   FOR EACH gnchelp WHERE gnchelp.dtlibera <= glb_dtmvtolt NO-LOCK
                          BREAK BY gnchelp.nmdatela
                                  BY gnchelp.nmrotina:

       IF   FIRST-OF(gnchelp.nmdatela)   THEN
            DO:
                 FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper 
                                    AND   craptel.nmdatela = gnchelp.nmdatela
                                    AND   craptel.nmrotina = ""
                                          NO-LOCK NO-ERROR.
                                          
                 aux_tldatela = craptel.tldatela.
            END.

       IF   LAST-OF(gnchelp.nmrotina)   THEN                
            DO:  
                 FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper 
                                    AND   craptel.nmdatela = gnchelp.nmdatela
                                    AND   craptel.nmrotina = gnchelp.nmrotina
                                          NO-LOCK NO-ERROR.                                                                       
                 CREATE w_telas.
                 ASSIGN w_telas.tldatela = STRING(gnchelp.nmdatela,"x(6)") + 
                                           "-" + aux_tldatela
                        w_telas.nmrotina = craptel.nmrotina
                        w_telas.nmoperad = STRING(gnchelp.cdoperad,"x(10)") + 
                                           "-" + gnchelp.nmoperad
                        w_telas.nrversao = gnchelp.nrversao
                        w_telas.dtlibera = STRING(gnchelp.dtlibera,
                                                         "99/99/99").
            END.
   END.

   /* telas nao liberadas */
   FOR EACH gnchelp WHERE gnchelp.dtlibera > glb_dtmvtolt NO-LOCK
                          BREAK BY gnchelp.nmdatela
                                  BY gnchelp.nmrotina:

       IF   FIRST-OF(gnchelp.nmdatela)   THEN
            DO:
                 FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper 
                                    AND   craptel.nmdatela = gnchelp.nmdatela
                                    AND   craptel.nmrotina = ""
                                          NO-LOCK NO-ERROR.
                                          
                 aux_tldatela = craptel.tldatela.
            END.
   
   
       FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper       AND
                                craptel.nmdatela = gnchelp.nmdatela   AND
                                craptel.nmrotina = gnchelp.nmrotina
                                NO-LOCK NO-ERROR.
                                                   
       CREATE w_telas.
       ASSIGN w_telas.tldatela = STRING(gnchelp.nmdatela,"x(6)") + 
                                 "-" + aux_tldatela
              w_telas.nmrotina = craptel.nmrotina
              w_telas.nmoperad = STRING(gnchelp.cdoperad,"x(10)") + 
                                 "-" + gnchelp.nmoperad
              w_telas.nrversao = gnchelp.nrversao
              w_telas.dtlibera = "  NAO   ".
   END.

   OPEN QUERY q_telas FOR EACH w_telas BY w_telas.tldatela
                                         BY w_telas.nmrotina.
   
   SET b_telas WITH FRAME f_telas.
   
END PROCEDURE.

/*...........................................................................*/

