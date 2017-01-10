/* ................................................................................
 include: wpgd0098.i
objetivo: criar uma lista de cooperativas, para que seja usada em campos
          do tipo "combo-box"
		  
Alterações: 06/07/2009 - Alteração CDOPERAD (Diego).

            15/12/2015 - Reordenação de cooperativas por nome (Jean Michel).

			06/12/2016 - P341-Automatização BACENJUD - Alterada a validação 
			             do departamento para que a mesma seja feita através
				         do código e não da descrição (Renato Darosci)
................................................................................ */
IF   AVAILABLE gnapses   THEN
     DO:
        FIND crapope WHERE crapope.cdcooper = gnapses.cdcooper  AND
		                   crapope.cdoperad = gnapses.cdoperad NO-LOCK NO-ERROR.
						   
		FOR EACH crapcop NO-LOCK BY crapcop.nmrescop:
        
            /* Implementa a segurança por Cooperativa */
            IF   gnapses.nvoperad <> 0                  AND
                 gnapses.cdcooper <> crapcop.cdcooper   AND
				(AVAIL crapope AND crapope.cddepart <> 20 )  THEN    /*  TI  */
                 NEXT.
        
            ASSIGN aux_crapcop = aux_crapcop + crapcop.nmrescop + "," + 
                                 STRING(crapcop.cdcooper) + ",".
        END.
        
        /* Tira a ultima "," */
        aux_crapcop = SUBSTRING(aux_crapcop, 1, LENGTH(aux_crapcop) - 1).
     END.
ELSE
     aux_crapcop = "".
