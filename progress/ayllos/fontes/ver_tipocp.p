/*.............................................................................

   Programa: Fontes/ver_tipocp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Outubro/2008                         Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa para Conectar/Desconectar GENERICO para Visualizar
               a Natureza Juridica.
    
   Alteracoes:
..............................................................................*/

DEF INPUT  PARAM par_natjurid AS INTEGER                             NO-UNDO.
DEF OUTPUT PARAM par_dsnatjur AS CHARACTER                           NO-UNDO.

FIND gncdntj WHERE gncdntj.cdnatjur = par_natjurid  NO-LOCK NO-ERROR.

IF   AVAILABLE gncdntj THEN
     par_dsnatjur = gncdntj.rsnatjur.
ELSE
     par_dsnatjur = "NAO CADASTRADO".

/*............................................................................*/
