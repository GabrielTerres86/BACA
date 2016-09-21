/* .............................................................................

   Programa: Fontes/sldapl.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/94.                           Ultima atualizacao: 07/07/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar o saldo das aplicacoes financeiras e mostrar
               o extrato das mesmas para a tela ATENDA.

   Alteracoes: 08/12/94 - Alterado para mostrar saldo e extrato de RDCA no
                          total de aplicacoes (Deborah).

               08/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               07/07/2006 - Ajustes para melhorar a performance (Edson).

............................................................................. */

{ includes/var_online.i }

{ includes/var_atenda.i }

DEF INPUT  PARAM par_flgextra AS LOGICAL                             NO-UNDO.

DEF        VAR aux_txaplica AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF        VAR aux_vlmoefix AS DECIMAL DECIMALS 4                    NO-UNDO.

/*

/*  Leitura da TR do dia do movimento  */

FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                   crapmfx.dtmvtolt = glb_dtmvtolt   AND
                   crapmfx.tpmoefix = 11 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapmfx   THEN
     DO:
         glb_cdcritic = 211.
         RETURN.
     END.
ELSE
     aux_vlmoefix = crapmfx.vlmoefix.

*/

ASSIGN aux_vltotapl = 0
       glb_cdcritic = 0.

/*  Totaliza saldo das aplicacoes  */

FOR EACH crapapl WHERE crapapl.cdcooper = glb_cdcooper   AND
                       crapapl.nrdconta = tel_nrdconta   AND
                       crapapl.dtresgat > glb_dtmvtolt NO-LOCK:

    IF   crapapl.tpaplica = 1   THEN
         aux_vltotapl = aux_vltotapl + crapapl.vlaplica + crapapl.vlaprmes +
                                       crapapl.vlaprmss + crapapl.vlaprpms.
    ELSE
    IF   crapapl.tpaplica = 2   THEN
         DO:
             FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper       AND
                                crapmfx.dtmvtolt = crapapl.dtmvtolt   AND
                                crapmfx.tpmoefix = 11 NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapmfx   THEN
                  DO:
                      glb_cdcritic = 211.
                      RETURN.
                  END.

             ASSIGN aux_txaplica = 1 + (crapapl.txaplica / 100)
                    aux_vltotapl = aux_vltotapl +
                                   ROUND(((crapapl.vlaplica /
                                           crapmfx.vlmoefix) * aux_vlmoefix) *
                                           aux_txaplica,2).
         END.

END.  /*  Fim do FOR EACH  --  crapapl  */

ASSIGN glb_cdcritic = 0.

IF   par_flgextra    THEN
     DO:
         EMPTY TEMP-TABLE crawext.  

         FOR EACH crapapl WHERE crapapl.cdcooper = glb_cdcooper   AND
                                crapapl.nrdconta = tel_nrdconta   AND
                                crapapl.dtresgat > glb_dtmvtolt   NO-LOCK:

             CREATE crawext.
             ASSIGN crawext.dtmvtolt = crapapl.dtmvtolt

                    crawext.dshistor = IF crapapl.tpaplica = 1
                                       THEN "RDC-Resgate: " +
                                          STRING(crapapl.dtresgat,"99/99/9999")
                                       ELSE "TP2-Resgate: " +
                                          STRING(crapapl.dtresgat,"99/99/9999")

                    crawext.nrdocmto = STRING(crapapl.nraplica,"zzzzz9") + "/" +
                                       STRING(crapapl.nrsubapl,"999").

             IF   crapapl.tpaplica = 1   THEN
                  crawext.vllanmto = crapapl.vlaplica + crapapl.vlaprmes +
                                     crapapl.vlaprmss + crapapl.vlaprpms.
             ELSE
             IF   crapapl.tpaplica = 2   THEN
                  DO:
                      FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper     AND
                                         crapmfx.dtmvtolt = crapapl.dtmvtolt AND
                                         crapmfx.tpmoefix = 11 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapmfx   THEN
                           DO:
                               glb_cdcritic = 211.
                               RETURN.
                           END.

                      ASSIGN aux_txaplica = 1 + (crapapl.txaplica / 100)
                             crawext.vllanmto = ROUND(((crapapl.vlaplica /
                                                        crapmfx.vlmoefix) *
                                                        aux_vlmoefix) *
                                                        aux_txaplica,2).
                  END.

         END.  /*  Fim do FOR EACH  --  crapapl  */

         RUN fontes/atenda_e.p.
     END.

/* .......................................................................... */

