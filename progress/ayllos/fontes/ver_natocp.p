/* .............................................................................

   Programa: Fontes/ver_natocp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : ZE
   Data    : Janeiro/2007                         Ultima Atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa para Conectar/Desconectar GENERICO para Visualizar
               a Natureza de Ocupacao.

............................................................................. */

/*{ includes/var_online.i }

{ includes/gg0000.i } */

DEF INPUT  PARAM par_cdnatopc AS INTEGER                             NO-UNDO.
DEF OUTPUT PARAM par_dsnatopc AS CHARACTER                           NO-UNDO.

FIND gncdnto WHERE gncdnto.cdnatocp = par_cdnatopc  NO-LOCK NO-ERROR.

IF   AVAILABLE gncdnto THEN
     par_dsnatopc = gncdnto.rsnatocp.
ELSE
     par_dsnatopc = "NAO CADASTRADO".
/* .......................................................................... */
