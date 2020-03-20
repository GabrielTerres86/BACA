/*
--
  PRB0041679
  Corrigir sequencia da central para corrigir o erro na integracao de convenio (pc_crps387) 
  A sequencia de exemplo sera a atual da Viacredi
--
Convenios que estao divergentes e serao corrigidos:
1: Oi Fixo

4: Casan

15: Vivo

33: Aguas de Joinville

48: Tim

57: Jornal SC

61: Jornal AN

65: Jornal DC

71: D-Kiros

*/
DECLARE
    
  CURSOR c1 IS
    SELECT *
      FROM gncontr g1
     WHERE 1 = 1 
       AND g1.cdcooper = 1
       AND g1.tpdcontr = 3   /* Integr.Arq. */
       AND g1.cdconven IN (1,4,15,33,48,57,61,65,71)      
       AND g1.nrsequen = ( SELECT MAX(NRSEQUEN)
                              FROM gncontr g2
                             WHERE 1 = 1
                               AND g2.cdcooper = g1.cdcooper
                               AND g2.tpdcontr = g1.tpdcontr 
                               AND g2.cdconven = g1.cdconven);      
                   
BEGIN
  dbms_output.put_line('Inicio do processamento');
  FOR r1 IN c1 LOOP
    
    BEGIN
      INSERT INTO gncontr
      (CDCOOPER, TPDCONTR, CDCONVEN, DTMVTOLT, DTCREDIT, NMARQUIV, QTDOCTOS, VLDOCTOS, VLTARIFA, VLAPAGAR, NRSEQUEN, VLDOCTO2, FLGMIGRA, CDSITRET)
      VALUES
      (3, R1.TPDCONTR, R1.CDCONVEN, R1.DTMVTOLT, R1.DTCREDIT,R1.NMARQUIV,0,0,0,0,R1.NRSEQUEN,0,0,0);
    EXCEPTION 
      WHEN OTHERS THEN
        dbms_output.put_line('Falha ao inserir na tabela gncontr, código convênio: '|| R1.CDCONVEN ||SQLERRM);
    END;
  END LOOP;
  
  COMMIT;
  dbms_output.put_line('Fim do processamento');
END;        
