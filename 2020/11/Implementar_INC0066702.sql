/*
  *** INC0066702 ***
  Correcao em registros para aplicar contorno em baixa com convenio 
  aplica contorno em erro de preenchimento na tela conven (erro operacional)
     - Data de Vencimento de 15, 16, 19 e 20 do 10/2020 para 10/11/2020
     - Codigo do Historico de 3383 para 3392
*/

UPDATE craplft
   SET dtvencto = '10/11/2020', cdhistor = 3392
 WHERE progress_recid IN (43332410, 43333976, 43334984, 43337877, 43337934, 43338925, 43339460, 43346325, 43346354, 
                          43360387, 43361234, 43364794, 43364801, 43364872, 43364928, 43364993, 43370043, 43370052, 
                          43370233, 43371163, 43371174, 43371182, 43373856, 43374079, 43374493, 43374543, 43393632, 
                          43396634, 43396637, 43400015, 43400095, 43403845, 43403852, 43407110, 43407120, 43407551, 
                          43409529, 43416737, 43417656, 43417676, 43417679, 43417712, 43417732, 43471661);

COMMIT;
