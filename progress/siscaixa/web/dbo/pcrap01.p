
/*---------------------------------------------------------------------*/
/*  pcrap01.p - Calcular a partir do nro do cheque o numero do talao   */
/*              e a posicao do cheque dentro do mesmo(Antigo numtal.p) */
/*---------------------------------------------------------------------*/
                                                         
DEF INPUT-OUTPUT PARAM  p-nro-calculo AS DEC   FORMAT ">>>>>>>>>>>>>9".   /* Nro conta */    
DEF INPUT-OUTPUT PARAM  p-nro-talao   AS INT.                             /* Nro Talão */       
DEF INPUT-OUTPUT PARAM  p-posicao     AS INT   FORMAT "z9".               /* Posição */    
DEF INPUT-OUTPUT PARAM  p-nro-folhas  AS INT.                             /* Nro Folhas */       

DEF   VAR aux_calculo  AS INT   NO-UNDO.
DEF   VAR aux_resto    AS INT   NO-UNDO.

IF   p-nro-folhas = 0   THEN
     p-nro-folhas = 20.

ASSIGN aux_calculo  = TRUNCATE(INTEGER(SUBSTRING(STRING(p-nro-calculo,"zzzzzzz9"),1,7)) / p-nro-folhas,0)

       aux_resto    = INTEGER(SUBSTRING(STRING(p-nro-calculo, "zzzzzzz9"),1,7)) MOD p-nro-folhas

       p-nro-talao  = IF aux_resto = 0 THEN aux_calculo  ELSE aux_calculo + 1

       p-posicao    = IF aux_resto = 0 THEN p-nro-folhas ELSE aux_resto

       p-nro-folhas = 0.

/* pcrap01.p */
