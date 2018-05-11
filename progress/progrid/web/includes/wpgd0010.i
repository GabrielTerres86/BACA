/* ..............................................................................
  Include: wpgd0010.i                                         Cria�ao: 29/08/2017
  
  Objetivo: Criar um vetor de programas, para utiliza�ao em diversos lugares onde
            o filtro por programas ser� necess�rio.
          
  Altera�oes:
  
.............................................................................. */

  ASSIGN vetorprogra = "-- TODOS --,0".

  FOR EACH crappgm WHERE crappgm.idsitpgm = 1 NO-LOCK
                      BY crappgm.nmprogra:

      IF TRIM(vetorprogra) <> "" THEN
        ASSIGN vetorprogra = vetorprogra + ",".
        
      ASSIGN vetorprogra = vetorprogra + TRIM(STRING(crappgm.nmprogra)) + "," + TRIM(STRING(crappgm.nrseqpgm)).

  END.