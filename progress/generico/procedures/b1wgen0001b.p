/*..............................................................................

   Programa: b1wgen0001b.p                  
   Autor   : David
   Data    : Outubro/2008                        Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : Obter natureza de ocupacao do associado (Chamado pela b1wgen0001)

   Alteracoes: 
                            
..............................................................................*/

DEF  INPUT PARAM par_cdnatjur AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM par_dsnatjur AS CHAR                                  NO-UNDO.

FIND gncdntj WHERE gncdntj.cdnatjur = par_cdnatjur NO-LOCK NO-ERROR.

IF  AVAILABLE gncdntj  THEN
    par_dsnatjur = gncdntj.rsnatjur.
ELSE
    par_dsnatjur = "NAO CADASTRADO".

/*............................................................................*/