/*.............................................................................
  
   Programa: Fontes/termo_compromisso.p
   Sistema : Conta-Corrente - Cooperativa de Credito 
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Junho/2009                         Ultima atualzacao:
   
   Dados referentes ao programa:
   
   Frequencia: Diario(On-line).
   Objetivo  : Imprimir o termo de compromisso da inscricao ao evento.
               
   NOTA      : Chamado por includes/pgdter.i. 

   Alteracoes: 

..............................................................................*/

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/b1wgen0039tt.i }
{ includes/var_sitpgd.i}

FIND FIRST crapass where crapass.cdcooper = glb_cdcooper no-lock.

par_flgrodar = TRUE.

ASSIGN aux_nmarqimp    = "rl/termo_compromisso.lst"

       glb_nmformul   = "80col".

{ includes/impressao.i }


/*............................................................................*/
