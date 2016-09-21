/* .............................................................................

   Programa: fontes/div1000.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
/*  div1000.p  --  Divide por mil e retorna o resto da divisao  */

{ includes/var1000.i }

ASSIGN glb_vldsaida = TRUNCATE(glb_vldentra / 1000,2)
       glb_vldresto = glb_vldentra - (glb_vldsaida * 1000).

/* .......................................................................... */
