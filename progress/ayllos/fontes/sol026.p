/* .............................................................................

   Programa: Fontes/sol026.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/92                        Ultima atualizacao: 02/12/2011
                                                                             
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL026.

   Alteracoes: 28/06/95 - Alterado para permitir solicitar no mes 6 (Deborah).

               01/08/97 - Alterado para utilizar 6 casas decimais para a taxa
                          de juros (Edson).

               27/12/2000 - Incluir semestral ou anual (Deborah).

               30/04/2004 - Ajustes na rotina de alteracao (Deborah).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               02/12/2011 - Retirada a opção "A" e substítuida pela procedure 
                            atualiza_sol026 da BO-b1wgen0128 (Isara - RKAM).
               
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_txjurcap AS DECIMAL FORMAT "zz9.999999"
                                       DECIMALS 6
                                       EXTENT 12                     NO-UNDO.

DEF        VAR tel_tpcalcul AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR ant_tpcalcul AS INT     FORMAT "9"                    NO-UNDO.

DEF        VAR ant_txjurcap AS DECIMAL DECIMALS 6 EXTENT 12          NO-UNDO.

DEF        VAR aux_nmmesano AS CHAR    EXTENT 12 INIT
                                       ["JANEIRO  ","FEVEREIRO",
                                        "MARCO    ","ABRIL    ",
                                        "MAIO     ","JUNHO    ",
                                        "JULHO    ","AGOSTO   ",
                                        "SETEMBRO ","OUTUBRO  ",
                                        "NOVEMBRO ","DEZEMBRO "]     NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_dstextab AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrmesini AS INT                                   NO-UNDO.
DEF        VAR aux_nrmesfin AS INT                                   NO-UNDO.
DEF        VAR aux_nrmestax AS INT                                   NO-UNDO.

FORM SKIP (1)
     "Opcao"          AT 09
     glb_cddopcao     AT 16 AUTO-RETURN
                            HELP "Entre com a opcao desejada (C)"
                            VALIDATE(glb_cddopcao = "C",
                                     "014 - Opcao errada.")
     "Mes"            AT 26
     "Taxa"           AT 46
     SKIP(1)
     "Janeiro"        AT 26
     tel_txjurcap[01] AT 40 "%"
     SKIP
     "Fevereiro"      AT 26
     tel_txjurcap[02] AT 40 "%"
     SKIP
     "Marco"          AT 26
     tel_txjurcap[03] AT 40 "%"
     SKIP
     "Abril"          AT 26
     tel_txjurcap[04] AT 40 "%"
     SKIP
     "Maio"           AT 26
     tel_txjurcap[05] AT 40 "%"
     SKIP
     "Junho"          AT 26
     tel_txjurcap[06] AT 40 "%"
     SKIP
     "Julho"          AT 26
     tel_txjurcap[07] AT 40 "%"
     SKIP
     "Agosto"         AT 26
     tel_txjurcap[08] AT 40 "%"
     SKIP
     "Setembro"       AT 26
     tel_txjurcap[09] AT 40 "%"
     SKIP
     "Outubro"        AT 26
     tel_txjurcap[10] AT 40 "%"
     SKIP
     "Novembro"       AT 26
     tel_txjurcap[11] AT 40 "%"
     SKIP
     "Dezembro"       AT 26
     tel_txjurcap[12] AT 40 "%"
     SKIP(1)
     WITH NO-LABELS TITLE COLOR MESSAGE glb_tldatela
          ROW 4 COLUMN 1 OVERLAY WIDTH 80 SIDE-LABELS FRAME f_sol026.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_sol026.
           
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL026"   THEN
                 DO:
                     HIDE FRAME f_sol026.
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

   ASSIGN glb_cddopcao = glb_cddopcao.
   
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 00             AND
                               craptab.cdacesso = "EXEJUROCAP"   AND
                               craptab.tpregist = 001
                               NO-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 115.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol026.
                     NEXT.
                 END.
            
            /* eliminado em 30/04/2004
            
            IF   NUM-ENTRIES(SUBSTR(craptab.dstextab,5,200),";") <> 12 THEN
                 DO:
                     glb_cdcritic = 504.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
            */
            
             ASSIGN tel_tpcalcul = INT(SUBSTR(craptab.dstextab,1,1))
                    aux_dstextab = SUBSTRING(craptab.dstextab,5,200).
                    
             DO aux_contador = 1 TO NUM-ENTRIES(aux_dstextab,";"):

               tel_txjurcap[aux_contador] = 
                                DECIMAL(ENTRY(aux_contador, 
                                        aux_dstextab,";")).
                             
            END.  /*  Fim do DO .. TO  */
            
            DISPLAY tel_txjurcap WITH FRAME f_sol026.
        END.
END.

/* .......................................................................... */
