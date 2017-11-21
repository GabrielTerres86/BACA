/*.............................................................................

   Programa: b1wgen0197tt.i                  
   Autor   : Lucas Reinert
   Data    : Maio/2017                       Ultima atualizacao: 21/11/2017

   Dados referentes ao programa:

   Objetivo  : Definicoes e criacao de temp-table referente a BO b1wgen0197.p

   Alteracoes: 14/11/2017 - Inclusao de novos campos (Jonata - RKAM P364).
		
			   21/11/2017 - Inclusao de novos campos (Jonata - RKAM P364).

.............................................................................*/

DEF TEMP-TABLE tt-inf-produto NO-UNDO               
  FIELD vlemprst AS DECIMAL
  FIELD vllimpro AS DECIMAL
  FIELD vllimdsc AS DECIMAL
  FIELD vlcompcr AS DECIMAL
  FIELD vllimcar AS DECIMAL
  FIELD vlresapl AS DECIMAL
  FIELD vlsrdrpp AS DECIMAL
  FIELD flcobran AS INTEGER 
  FIELD flseguro AS INTEGER 
  FIELD flconsor AS INTEGER
  FIELD flgctitg AS INTEGER 
  FIELD flgccbcb AS INTEGER 
  FIELD flgccbdb AS INTEGER 
  FIELD qtfdcuso AS INTEGER 
  FIELD qtchqdev AS INTEGER 
  FIELD qtreqtal AS INTEGER 
  FIELD qtchqcan AS INTEGER 
  FIELD inarqcbr AS INTEGER
  FIELD flgbinss AS INTEGER
  FIELD flpdbrde AS INTEGER
  FIELD flgcrmag AS INTEGER
  FIELD flgagend AS INTEGER
  FIELD flgcarta AS INTEGER
  FIELD qtfdcest AS INTEGER
  FIELD flsegauto  AS INTEGER
  FIELD flsegvida  AS INTEGER.