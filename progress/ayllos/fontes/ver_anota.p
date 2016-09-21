/* .............................................................................

   Programa: Fontes/ver_anota.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Dezembro/2001                       Ultima alteracao: 13/11/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela ANOTA.

   Alteracoes: Unificacao dos bancos - SQLWorks - Eder
            
               13/11/2008 - Limpar glb_cdcritic na saida do programa (David).
               
............................................................................. */

DEF INPUT PARAM par_nrdconta AS INT                                  NO-UNDO.

{ includes/var_online.i } 

{ includes/var_anota.i "NEW" }

ASSIGN glb_cdcritic = 0
       aux_nmarqimp = ""
       tel_nrdconta = par_nrdconta.

FIND FIRST crapobs WHERE crapobs.cdcooper = glb_cdcooper  AND
                         crapobs.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapobs   THEN
     RETURN.

ASSIGN aux_recidobs = 0
       aux_nrseqdig = 0
       aux_tipconsu = yes.

RUN fontes/impanotacoes.p.

RUN fontes/visualiza_anotacoes.p.

ASSIGN glb_cdcritic = 0
       glb_cdprogra = "ATENDA".
                                                
/* .......................................................................... */
