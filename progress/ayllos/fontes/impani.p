/* .............................................................................

   Programa: Fontes/impani.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson/Evandro
   Data    : Dezembro/2004  

   Dados referentes ao programa:                 Ultima Alteracao: 30/05/2014

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IMPANI.

   Alteracoes: 01/02/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               12/01/2011 - Incluido format para o campo nmprimtl.
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)  
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

DEF STREAM str_1.     

{ includes/var_online.i }

DEF        VAR tel_nrmesani AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtassoci AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR rel_dsobserv AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmextmes AS CHAR    FORMAT "x(10)"  EXTENT 12 
                            INIT["JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO",
                                 "JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO",
                                 "NOVEMBRO","DEZEMBRO"]              NO-UNDO.

/* variaveis para impressao */
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmmesref AS CHAR    FORMAT "x(014)"               NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

FORM SKIP(6)
     tel_cdagenci  AT 35  LABEL "PA"
                          HELP  "Entre com o PA do qual deseja listar."
                          VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper =
                                                          glb_cdcooper   AND
                                                          crapage.cdagenci =
                                                         INPUT tel_cdagenci),
                                   "962 - PA nao cadastrado.")
     SKIP(1)
     tel_nrmesani  AT 35  LABEL "Mes"
                          HELP  "Entre com o nro. do mes de referencia."
                          VALIDATE(INPUT tel_nrmesani >  0   AND
                                   INPUT tel_nrmesani <= 12,
                            "013 - Data errada - o mes deve ser entre 1 e 12.")
     SKIP(7)
     WITH ROW 4 SIDE-LABELS OVERLAY TITLE glb_tldatela WIDTH 80 FRAME f_impani.

FORM crapass.nrdconta   LABEL "CONTA/DV"
     SPACE(2)
     crapass.dtnasctl   LABEL "DATA NASC."
     SPACE(2)
     crapass.nmprimtl   LABEL "NOME" FORMAT "x(40)"
     SPACE(2)
     rel_dsobserv       LABEL "  OBSERVACAO"
     WITH DOWN NO-BOX NO-LABELS FRAME f_associados.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:
  
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_cdagenci tel_nrmesani WITH FRAME f_impani.

      IF   aux_cddopcao <>  glb_cddopcao THEN
           DO:
               { includes/acesso.i }
           END.
      
      IF   tel_nrmesani = 0   THEN
           tel_nrmesani = MONTH(glb_dtmvtolt).
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         aux_confirma = "N".

         glb_cdcritic = 78.
         RUN fontes/critic.p.
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         glb_cdcritic = 0.
         LEAVE.
      END.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
           aux_confirma <> "S"                  THEN
           DO:
               glb_cdcritic = 79.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
           END.
           
      MESSAGE "Aguarde ...".
           
      INPUT THROUGH basename `tty` NO-ECHO.
      SET aux_nmendter WITH FRAME f_terminal.
      INPUT CLOSE. 
      
      aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                            aux_nmendter.

      UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
      ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

      ASSIGN glb_cdcritic    = 0
             glb_nrdevias    = 1
             glb_cdempres    = 11          
             glb_nmformul    = "80col"
             glb_cdrelato[1] = 406.
      
      { includes/cabrel080_1.i }
   
      OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 63.

      VIEW STREAM str_1 FRAME f_cabrel080_1.
      
      FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND 
                         crapage.cdagenci = tel_cdagenci NO-LOCK NO-ERROR.
      
      /* para fazer espacamento entre-linhas de 1/6" */
      PUT STREAM str_1 "\0332\022\024\033\120".
      
      PUT STREAM str_1 "PA  "
                       tel_cdagenci
                       " - "
                       crapage.nmresage
                       "REF.: "          AT 50
                       rel_nmextmes[tel_nrmesani]
                       SKIP(1).
      
      aux_qtassoci = 0.
      
      FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper          AND
                             crapass.cdagenci = tel_cdagenci          AND
                             crapass.dtdemiss = ?                     AND
                             crapass.inpessoa = 1                     AND
                             MONTH(crapass.dtnasctl) = tel_nrmesani
                             NO-LOCK BY DAY(crapass.dtnasctl)
                                        BY crapass.nmprimtl:
          
          DISPLAY STREAM str_1
                  crapass.nrdconta
                  crapass.dtnasctl
                  crapass.nmprimtl 
                  "______________"  @  rel_dsobserv
                  WITH FRAME f_associados.
                  
          DOWN STREAM str_1 WITH FRAME f_associados.

          IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
               DO:
                   PUT STREAM str_1 "PA  "
                                    tel_cdagenci
                                    " - "
                                    crapage.nmresage
                                    "REF.: "          AT 50
                                    rel_nmextmes[tel_nrmesani]
                                    SKIP(1).
               END.
          
          aux_qtassoci = aux_qtassoci + 1.
      
      END.  /*  Fim do FOR EACH -- crapass  */
      
      PUT STREAM str_1 SKIP(1)
                       "QTD: "    AT 19
                       aux_qtassoci
                       SKIP.
      
      OUTPUT STREAM str_1 CLOSE.

      HIDE MESSAGE NO-PAUSE.
                         
      /* somente para impressao */
      FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

      { includes/impressao.i }
                          
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "IMPANI"   THEN
                 DO:
                     HIDE FRAME f_impani.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
           
END.  /*  Fim do DO WHILE TRUE  */

/* ......................................................................... */

