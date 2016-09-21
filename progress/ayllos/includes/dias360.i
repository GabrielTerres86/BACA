/*..............................................................................

   Programa: dias360.i
   Autor   : James Prust Junior
   Data    : 08/01/2014                        Ultima atualizacao: 
    
   Dados referentes ao programa:

   Objetivo  : Include para calcular quantidade de dias entre duas datas
               com base em um ano de 360 dias.
   
   Alteracoes: 
   
..............................................................................*/
ASSIGN aux_diapagto = DAY(aux_dtdpagto)
       aux_anoinici = YEAR(aux_dtdinici)
       aux_mesinici = MONTH(aux_dtdinici)
       aux_diainici = DAY(aux_dtdinici)
       aux_anofinal = YEAR(aux_dtdfinal)
       aux_mesfinal = MONTH(aux_dtdfinal)
       aux_diafinal = DAY(aux_dtdfinal).
      
IF aux_diainici = 31 THEN
   ASSIGN aux_diainici = 30.

IF aux_diafinal = 31 THEN
   ASSIGN aux_diafinal = 30.
         
IF (aux_diapagto > 28) AND (NOT aux_ehmensal)THEN
   DO:
       IF ((aux_mesfinal = 2) AND (aux_diafinal >= 28) AND 
           (aux_diafinal <> aux_diapagto)) THEN
          ASSIGN aux_diafinal = IF aux_diapagto = 31 THEN
                                   30
                                ELSE
                                   aux_diapagto.
   END.
ELSE
   IF aux_ehmensal THEN
      DO:
          ASSIGN aux_diafinal = 30.
      END.

IF ABS(aux_anofinal - aux_anoinici) = 0 THEN
   DO:
       ASSIGN aux_qtdedias = (aux_mesfinal - aux_mesinici) * 30 + 
                             aux_diafinal - aux_diainici.
   END.
ELSE
   DO:
       ASSIGN aux_qtdedias = ABS(aux_anofinal - aux_anoinici - 1) * 360 + 
                             360 - aux_mesinici * 30 +  30 - aux_diainici + 
                             30 * ( aux_mesfinal - 1) + aux_diafinal.
   END.
/* ......................................................................... */
