/* .............................................................................

   Programa: fontes/real.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
/*  real.p  --  Converte cruzeiros reais para REAIS  */

{ includes/var_real.i }

ASSIGN glb_vldsaida = TRUNCATE(glb_vldentra / glb_vldaurvs,2)
       glb_vldresto = glb_vldentra - (glb_vldsaida * glb_vldaurvs).

/* .......................................................................... */
