/* .............................................................................

   Programa: Includes/lotreqc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92.                     Ultima atualizacao: 30/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela lotreq.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Magui).

               12/11/2004 - Exibir o nome do operador (Evandro).

               08/12/2005 - Incluir tratamento para conta ITG (Magui).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 
............................................................................. */

FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper       AND   
                   craptrq.cdagelot = INPUT tel_cdagelot AND
                   craptrq.tprequis = 0                  AND
                   craptrq.nrdolote = INPUT tel_nrdolote NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptrq   THEN
     DO:
         glb_cdcritic = 60.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_lotreq NO-PAUSE.

         ASSIGN tel_cdagelot = aux_cdagelot
                tel_nrdolote = aux_nrdolote.

         DISPLAY tel_cdagelot tel_nrdolote WITH FRAME f_lotreq.
         NEXT.
     END.

ASSIGN tel_qtdiferq = craptrq.qtcomprq - craptrq.qtinforq
       tel_qtdifetl = craptrq.qtcomptl - craptrq.qtinfotl
       tel_qtdifeen = craptrq.qtcompen - craptrq.qtinfoen.
       
FIND crapope WHERE  crapope.cdcooper = glb_cdcooper     AND
                    crapope.cdoperad = craptrq.cdoperad NO-LOCK NO-ERROR.

IF   AVAILABLE crapope   THEN
     tel_nmoperad = crapope.nmoperad.
       

DISPLAY craptrq.qtinforq craptrq.qtcomprq tel_qtdiferq
        craptrq.qtinfotl craptrq.qtcomptl tel_qtdifetl
        craptrq.qtinfoen craptrq.qtcompen tel_qtdifeen
        tel_nmoperad     WITH FRAME f_lotreq.

/* .......................................................................... */
