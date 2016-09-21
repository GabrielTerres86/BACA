/* .............................................................................

   Programa: Fontes/lanreq.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92.                     Ultima atualizacao: 17/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANREQ.

   Alteracoes: 13/06/94 - Alterado para acessar as tabelas de contas de convenio

               02/04/98 - Tratamento para milenio e troca para V8

               13/11/00 - Alterar nrdolote p/6 posicoes (Magui/Planner).

             14/11/2002 - Ler lotes gerados novo caixa (Magui).

             11/12/2002 - Permitir lotes do novo caixa (Magui).

             13/02/2003 - Usar agencia e numero do lote para separar
                          as agencias (Magui).

             20/04/2004 - Nao permitir lotes do caixa on_line (Magui).

             17/03/2005 - Verificar se Conta Integracao(Mirtes)

             07/12/2005 - Adequacao para uso do crapfdc (Magui). 

             19/01/2006 - Funcao para consistir se quantidade de folhas 
                          informada eh multiplo de 4 (Julio)

             01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
             
             08/02/2007 - Modificacao do uso dos indices, adequacao ao BANCOOB
                          e uso de BOs (Evandro).
                          
             19/03/2007 - Alterado HELP do campo tel_nrctachq (Evandro).
             
             29/09/2009 - Adaptacoes projeto IF CECRED (Guilherme).
             
             06/09/2011 - Adaptacoes para projeto Lista Negra (Adriano).
             
             07/05/2013 - Incluido a declaracao da variavel aux_dsoperac
                          (Adriano).
             
             14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).                          
                            
             17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                          nao cadastrado.". (Reinert)                            
                          
             27/06/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                          PinPad Novo (Lucas Lunelli - [PROJ290])
                          
............................................................................. */


{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF   VAR tel_cdagelot           AS INT     FORMAT "zz9"              NO-UNDO.
DEF   VAR tel_nrdolote           AS INT     FORMAT "zzz,zz9"          NO-UNDO.
DEF   VAR tel_qtinforq           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR tel_qtcomprq           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR tel_qtdiferq           AS INT     FORMAT "z,zz9-"           NO-UNDO.
DEF   VAR tel_qtinfotl           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR tel_qtcomptl           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR tel_qtdifetl           AS INT     FORMAT "z,zz9-"           NO-UNDO.
DEF   VAR tel_qtinfoen           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR tel_qtcompen           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR tel_qtdifeen           AS INT     FORMAT "z,zz9-"           NO-UNDO.
DEF   VAR tel_qtreqtal           AS INT     FORMAT "z9"               NO-UNDO.
DEF   VAR tel_nrinichq           AS INT     FORMAT "zzz,zzz,9"        NO-UNDO.
DEF   VAR tel_nrfinchq           AS INT     FORMAT "zzz,zzz,9"        NO-UNDO.
DEF   VAR tel_nrseqdig           AS INT     FORMAT "zz,zz9"           NO-UNDO.
DEF   VAR tel_reganter           AS CHAR    FORMAT "x(76)" EXTENT 6   NO-UNDO.
DEF   VAR tel_tprequis           LIKE crapreq.tprequis                NO-UNDO.
DEF   VAR tel_cdbanchq           LIKE crapfdc.cdbanchq                NO-UNDO.
DEF   VAR tel_cdagechq           LIKE crapfdc.cdagechq                NO-UNDO.
DEF   VAR tel_nrctachq           LIKE crapfdc.nrctachq                NO-UNDO.
DEF   VAR par_cdagechq           LIKE crapfdc.cdagechq                NO-UNDO.

DEF   VAR aux_cdagelot           AS INT     FORMAT "zz9"              NO-UNDO.
DEF   VAR aux_nrseqdig           AS INT     FORMAT "zzzz9"            NO-UNDO.
DEF   VAR aux_nrdolote           AS INT     FORMAT "zzz,zz9"          NO-UNDO.
DEF   VAR aux_qtinforq           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR aux_qtinfotl           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR aux_qtinfoen           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR aux_qtcomprq           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR aux_qtcomptl           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR aux_qtcompen           AS INT     FORMAT "z,zz9"            NO-UNDO.
DEF   VAR aux_qtdiferq           AS INT     FORMAT "z,zz9-"           NO-UNDO.
DEF   VAR aux_qtdifetl           AS INT     FORMAT "z,zz9-"           NO-UNDO.
DEF   VAR aux_qtdifeen           AS INT     FORMAT "z,zz9-"           NO-UNDO.
DEF   VAR aux_nrdconta           AS INT     FORMAT "zzzz,zzz,9"       NO-UNDO.
DEF   VAR aux_nrdctabb           AS INT     FORMAT "zzzz,zzz,9"       NO-UNDO.
DEF   VAR aux_tprequis           LIKE crapreq.tprequis                NO-UNDO.
DEF   VAR aux_seqatual           LIKE crapfdc.nrseqems                NO-UNDO.

DEF   VAR aux_nrinichq           AS INT                               NO-UNDO.
DEF   VAR aux_nrfinchq           AS INT                               NO-UNDO.
DEF   VAR aux_qtreqtal           AS INT                               NO-UNDO.
DEF   VAR aux_nrinital           AS INT                               NO-UNDO.
DEF   VAR aux_nrfintal           AS INT                               NO-UNDO.
DEF   VAR aux_nrcheque           AS INT                               NO-UNDO.
DEF   VAR aux_num_cheque_inicial AS INTE                              NO-UNDO.
DEF   VAR aux_num_cheque_final   AS INTE                              NO-UNDO.
DEF   VAR aux_nrseqems           AS INTE                              NO-UNDO.
DEF   VAR aux_qttalent           AS INTE                              NO-UNDO.
DEF   VAR aux_tpchqerr           AS LOG                               NO-UNDO.  
DEF   VAR aux_confirma           AS CHAR    FORMAT "!(1)"             NO-UNDO.
DEF   VAR aux_flgerros           AS LOGI                              NO-UNDO.
DEF   VAR aux_regexist           AS LOGI                              NO-UNDO.
DEF   VAR aux_contador           AS INT                               NO-UNDO.
DEF   VAR aux_cddopcao           AS CHAR                              NO-UNDO.
DEF   VAR aux_flgretor           AS LOGI                              NO-UNDO.
DEF   VAR aux_lsconta1           AS CHAR                              NO-UNDO.
DEF   VAR aux_dsoperac           AS CHAR                              NO-UNDO.

/* Para o uso da BO */
DEF   VAR h-b1crap05             AS HANDLE                            NO-UNDO.
DEF   VAR h-b1crap06             AS HANDLE                            NO-UNDO.
DEF   VAR h-b1wgen0110           AS HANDLE                            NO-UNDO.

DEF TEMP-TABLE tt-taloes
    FIELD nrtalao           AS DECI
    FIELD nrinicial         AS DECI
    FIELD nrfinal           AS DECI.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE COLOR MESSAGE " Lancamentos de Requisicoes "
                      FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")

     "Informado   Computado   Diferenca"  AT 39
     SKIP
     "Requisicoes       :"  AT 20
     tel_qtinforq    AT 42 NO-LABEL
     tel_qtcomprq    AT 54 NO-LABEL
     tel_qtdiferq    AT 66 NO-LABEL
     SKIP
     tel_cdagelot    AT  5 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o numero do PA."
                        VALIDATE (CAN-FIND (crapage WHERE crapage.cdcooper = 
                                                          glb_cdcooper   AND
                                                          crapage.cdagenci =
                                  tel_cdagelot),"962 - PA nao cadastrado.")
     "Taloes solicitados:" AT 20
     tel_qtinfotl    AT 42 NO-LABEL
     tel_qtcomptl    AT 54 NO-LABEL
     tel_qtdifetl    AT 66 NO-LABEL
     SKIP
     tel_nrdolote    AT  3 LABEL "Caixa"
                        HELP "Entre com o numero do caixa."
                        VALIDATE (tel_nrdolote > 0,
                                  "058 - Numero do caixa deve ser informado.")
 
     "Taloes entregues  :"  AT 20
     tel_qtinfoen    AT 42 NO-LABEL
     tel_qtcompen    AT 54 NO-LABEL
     tel_qtdifeen    AT 66 NO-LABEL
     SKIP
     "------- Talao a ser entregue -------"     AT 35
     SKIP
     "Cta.Chq/dv   Tipo  Talonarios    Banco   Agencia   Inicial"   AT  2
     "Final    Seq."                                                AT 66
     SKIP(1)
     tel_nrctachq AT  2 NO-LABEL AUTO-RETURN  FORMAT "zzzz,zzz,9"
        HELP "So solicitar informe cta associado, demais operacoes cta cheque"
     tel_tprequis AT 17 NO-LABEL AUTO-RETURN
                        HELP "Informe o tipo de requisicao = 1-Normal 2-TB"
                        VALIDATE(tel_tprequis = 1 OR tel_tprequis = 2 OR
                                 tel_tprequis = 0,
                        "014 - Opcao Errada")
            
     tel_qtreqtal AT 25 NO-LABEL AUTO-RETURN
                        HELP "Entre com a quantidade de talonarios."

     tel_cdbanchq AT 35 NO-LABEL AUTO-RETURN
                        HELP "Informe o banco do cheque"
                        
     tel_cdagechq AT 45 NO-LABEL AUTO-RETURN  FORMAT "zzz9"
 
     tel_nrinichq AT 51 NO-LABEL AUTO-RETURN
                        HELP "Entre com a numeracao inicial."

     tel_nrfinchq AT 62 NO-LABEL AUTO-RETURN
                        HELP "Entre com a numeracao final."

     tel_nrseqdig       NO-LABEL

     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanreq.

FORM tel_reganter[1] NO-LABEL  tel_reganter[2] NO-LABEL
     tel_reganter[3] NO-LABEL  tel_reganter[4] NO-LABEL
     tel_reganter[5] NO-LABEL  tel_reganter[6] NO-LABEL
     WITH ROW 14 COLUMN 3 OVERLAY NO-BOX FRAME f_regant.

FORM crapreq.nrdctabb  
     crapreq.tprequis  AT 17
     crapreq.qtreqtal  AT 24
     crapreq.nrinichq  AT 51
     crapreq.nrfinchq  AT 62
     crapreq.nrseqdig
     WITH ROW 14 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.
 ON LEAVE OF tel_cdbanchq IN FRAME f_lanreq DO:
 
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
 
    /* Carrega a agencia de acordo com cada banco */
    
    IF   INPUT tel_cdbanchq = 1   THEN
         /* Banco do Brasil - sem DV */
         tel_cdagechq = INT(SUBSTRING(STRING(crapcop.cdagedbb),1,
                            LENGTH(STRING(crapcop.cdagedbb)) - 1)).
    ELSE
    IF   INPUT tel_cdbanchq = 756   THEN
         tel_cdagechq = crapcop.cdagebcb. /* BANCOOB */
    ELSE
         tel_cdagechq = crapcop.cdagectl.
         
    DISPLAY tel_cdagechq WITH FRAME f_lanreq.
 END.     
/* Buscar a agencia */
FUNCTION f_multiplo4 RETURN LOGICAL(INPUT par_nrinichq AS INTEGER,
                                    INPUT par_nrfimchq AS INTEGER):

   par_nrinichq = INT(TRUNC(par_nrinichq / 10, 0)).
   par_nrfimchq = INT(TRUNC(par_nrfimchq / 10, 0)).

   RETURN  ((par_nrfimchq - par_nrinichq + 1) MODULO 4) = 0 AND
            (par_nrfimchq - par_nrinichq) > 0.   
END.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       aux_flgretor = FALSE
       tel_nrctachq = 0
       tel_qtreqtal = 0
       tel_nrinichq = 0
       tel_nrfinchq = 0
       tel_nrseqdig = 1
       tel_tprequis = 1.

IF   glb_nmtelant = "LOTREQ"   THEN
     ASSIGN tel_cdagelot = glb_cdagenci
            tel_nrdolote = glb_nrdolote.
PAUSE(0).

DISPLAY glb_cddopcao tel_cdagelot tel_nrdolote tel_nrctachq tel_tprequis
        tel_qtreqtal tel_nrinichq tel_nrfinchq tel_nrseqdig
        WITH FRAME f_lanreq.

CLEAR FRAME f_regant NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   CLEAR FRAME f_regant NO-PAUSE.
   CLEAR FRAME f_lanreq  NO-PAUSE.
   CLEAR FRAME f_lanctos NO-PAUSE.
   HIDE FRAME f_lanctos.

   DISPLAY glb_cddopcao tel_cdagelot tel_nrdolote 
           WITH FRAME f_lanreq.
   
   NEXT-PROMPT tel_cdagelot WITH FRAME f_lanreq.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic = 0   THEN
           DO:
               IF   NOT aux_flgretor   THEN
                    IF   tel_cdagelot <> 0   AND
                         tel_nrdolote <> 0   THEN
                         LEAVE.
           END.

      REPEAT ON ENDKEY UNDO, LEAVE:

         SET glb_cddopcao tel_cdagelot tel_nrdolote 
                          WITH FRAME f_lanreq.

         IF   tel_cdagelot = 0  THEN  
              DO:
                  glb_cdcritic = 15.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  NEXT-PROMPT tel_cdagelot WITH FRAME f_lanreq.
                  NEXT.
              END.
              
         FIND crapage WHERE  crapage.cdcooper = glb_cdcooper  AND 
                             crapage.cdagenci = tel_cdagelot  NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE crapage   THEN
              DO:
                  glb_cdcritic = 15.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  NEXT-PROMPT tel_cdagelot WITH FRAME f_lanreq.
                  NEXT.
              END.
                        
         IF   glb_cddopcao <> "C"    AND
             (tel_nrdolote >= 19000  AND
              tel_nrdolote <= 19999) THEN
              DO:
                  glb_cdcritic = 261.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  NEXT-PROMPT tel_nrdolote WITH FRAME f_lanreq.
                  NEXT.
              END.
         
         LEAVE.
      
      END.

      LEAVE.
       
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANREQ"   THEN
                 DO:
                     HIDE FRAME f_lanreq.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
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

   ASSIGN aux_cdagelot = tel_cdagelot
          aux_nrdolote = tel_nrdolote
          aux_flgretor = TRUE.

   IF   INPUT glb_cddopcao = "A" THEN
        DO:
            BELL.
            MESSAGE "ROTINA NAO DISPONIVEL".
            /* { includes/lanreqa.i } */

        END.
   ELSE
   IF   INPUT glb_cddopcao = "C" THEN
        DO:
            { includes/lanreqc.i }
        END.
   ELSE
   IF   INPUT glb_cddopcao = "E"   THEN
        DO:
            { includes/lanreqe.i }
        END.
   ELSE
   IF   INPUT glb_cddopcao = "I"   THEN
        DO:
            { includes/lanreqi.i }
        END.
        
END.

/* .......................................................................... */

