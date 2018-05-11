/* ..............................................................................
  Include: wpgd0010.i                                         Criaçao: 29/08/2017
  
  Objetivo: Criar um vetor de programas, para utilizaçao em diversos lugares onde
            o filtro por programas será necessário.
          
  Alteraçoes:
  
.............................................................................. */

  ASSIGN vetorprogra = "-- TODOS --,0".

  FOR EACH crappgm WHERE crappgm.idsitpgm = 1 NO-LOCK
                      BY crappgm.nmprogra:

      IF TRIM(vetorprogra) <> "" THEN
        ASSIGN vetorprogra = vetorprogra + ",".
        
      ASSIGN vetorprogra = vetorprogra + TRIM(STRING(crappgm.nmprogra)) + "," + TRIM(STRING(crappgm.nrseqpgm)).

  END.