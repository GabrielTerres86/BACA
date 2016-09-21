/* ..........................................................................

   Programa: Fontes/qttalona.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/98.                            Ultima atualizacao: 02/10/2007

   Dados referentes ao programa:

   Frequencia: Sub-rotina (Batch - Background).
   Objetivo  : Calcular a quantidade de folhas do associado disponivel.

   Alteracao : 02/07/99 - Descartar cheques de transferencia (odair)

               21/08/2002 - Considerar apenas os cheques (Edson):
                            0 - Nao entraram
                            1 - Com contra-ordem
                            2 - Com alerta
                            
               10/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               02/10/2007 - Verificar tambem folhas retiradas no mes (Julio).

............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }

DEF INPUT  PARAMETER aux_dtmvtolt AS DATE                       NO-UNDO.    
DEF OUTPUT PARAMETER aux_qtchqtal AS INT                        NO-UNDO.
DEF OUTPUT PARAMETER aux_qtfolret AS INT                        NO-UNDO.

DEF VAR aux_flgordem AS LOGICAL                                 NO-UNDO.
DEF VAR aux_dtinicio AS DATE                                    NO-UNDO.

ASSIGN aux_dtinicio = DATE(MONTH(aux_dtmvtolt),01,YEAR(aux_dtmvtolt)).

FOR EACH crapfdc WHERE crapfdc.cdcooper  = glb_cdcooper   AND
                       crapfdc.nrdconta  = tel_nrdconta   AND
                       crapfdc.dtemschq <> ?              AND
                       crapfdc.dtretchq <> ?              AND
                       crapfdc.tpcheque = 1  NO-LOCK:

    IF   CAN-DO("0,1,2",STRING(crapfdc.incheque))   THEN
         aux_qtchqtal = aux_qtchqtal + 1.
         
    IF   crapfdc.dtretchq >= aux_dtinicio  THEN
         aux_qtfolret = aux_qtfolret + 1.

END.   /*  Fim do FOR EACH  --  Leitura do cadastro de cheques  */

/* .......................................................................... */

