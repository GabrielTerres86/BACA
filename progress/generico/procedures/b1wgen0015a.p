/*..............................................................................

   Programa: b1wgen0015a.p                  
   Autor   : David
   Data    : Junho/2008                        Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : Obter estado civil do titular (Chamada pela b1wgen0015)

   Alteracoes: 
                            
..............................................................................*/

DEF  INPUT PARAM par_cdestcvl AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM par_dsestcvl AS CHAR                                  NO-UNDO.

/** Estado Civil **/
FIND gnetcvl WHERE gnetcvl.cdestcvl = par_cdestcvl NO-LOCK NO-ERROR.

IF  AVAILABLE gnetcvl  THEN 
    ASSIGN par_dsestcvl = gnetcvl.dsestcvl. 
ELSE 
    ASSIGN par_dsestcvl = "NAO INFORMADO".

/*............................................................................*/