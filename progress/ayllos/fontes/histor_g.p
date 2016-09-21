/*..............................................................................
   
   Programa: fontes/histor_g.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2008                      Ultima atualizacao: 04/06/2010
   
   Dados referentes ao programa:
   
   Frequencia: Diario (On-Line)
   Objetivo  : Atualizar tarifas da tabela generica de convenios.

   Alteracoes: 26/11/2009 - Atualiza as tarifas na tabela gnconve para os
                            convenios inativos (Elton).
                            
               04/06/2010 - Incluido novo parametro referente a tarifa TAA 
                            (Elton).             
..............................................................................*/

DEF INPUT PARAM par_cdhistor AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_vltrfcxa AS DECI                                   NO-UNDO.
DEF INPUT PARAM par_vltrfnet AS DECI                                   NO-UNDO.
DEF INPUT PARAM par_vltrfdeb AS DECI                                   NO-UNDO.
DEF INPUT PARAM par_vltrftaa AS DECI                                   NO-UNDO.

FOR EACH gnconve WHERE (gnconve.cdhiscxa = par_cdhistor  OR
                        gnconve.cdhisdeb = par_cdhistor) EXCLUSIVE-LOCK:

    IF  gnconve.cdhiscxa = par_cdhistor  THEN
        ASSIGN gnconve.vltrfcxa = par_vltrfcxa
               gnconve.vltrfnet = par_vltrfnet 
               gnconve.vltrftaa = par_vltrftaa.

    IF  gnconve.cdhisdeb = par_cdhistor  THEN
        ASSIGN gnconve.vltrfdeb = par_vltrfdeb.

END.
                  
/*............................................................................*/
