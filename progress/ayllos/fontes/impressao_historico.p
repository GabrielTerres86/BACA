/*.............................................................................

   Programa: Fontes/impressao_historico.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Fevereiro/2011                         Ultima atualzacao:

   Dados referentes ao programa:

   Frequencia: Diario(On-line).
   Objetivo  : Imprimir o historico da participacao dos eventos.

   NOTA      : Chamado por includes/pgdhst.i.

   Alteracoes:

.............................................................................*/

DEF INPUT PARAM par_nmarqimp AS CHAR                                NO-UNDO.

{ includes/var_online.i } 
{ sistema/generico/includes/b1wgen0039tt.i }
{ includes/var_sitpgd.i }
      

DEF VAR aux_contador AS INTE                                        NO-UNDO.


FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK.

par_flgrodar = TRUE.

ASSIGN aux_nmarqimp = par_nmarqimp
       glb_nmformul = "132col".

{ includes/impressao.i }
               
/* ......................................................................... */
