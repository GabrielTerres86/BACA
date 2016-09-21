/*..............................................................................

   Programa: b1wgen0001a.p                  
   Autor   : David
   Data    : Abril/2008                        Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : Obter natureza de ocupacao do associado (Chamado pela b1wgen0001)

   Alteracoes: 
                            
..............................................................................*/

DEF  INPUT PARAM par_cdnatopc AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM par_dsnatopc AS CHAR                                  NO-UNDO.

FIND gncdnto WHERE gncdnto.cdnatocp = par_cdnatopc NO-LOCK NO-ERROR.

IF  AVAILABLE gncdnto  THEN
    par_dsnatopc = gncdnto.rsnatocp.
ELSE
    par_dsnatopc = "NAO CADASTRADO".

/*............................................................................*/