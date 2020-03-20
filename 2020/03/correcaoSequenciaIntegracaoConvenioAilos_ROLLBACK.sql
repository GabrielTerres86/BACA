/*
--
  PRB0041679
  Corrigir sequencia da central para corrigir o erro na integracao de convenio (pc_crps387) 
  A sequencia de exemplo sera a atual da Viacredi
--
Convenios que estao divergentes e serao desfeitos o script com commit:
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
    SELECT ROWID
      FROM gncontr g1
     WHERE 1 = 1 
       AND g1.cdcooper = 3
       AND g1.tpdcontr = 3   /* Integr.Arq. */
       AND g1.cdconven IN (1,4,15,33,48,57,61,65,71) 
       AND g1.vldoctos = 0
       AND g1.vltarifa = 0
       AND g1.vlapagar = 0
       AND g1.vldocto2 = 0
       AND g1.cdsitret = 0   
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
      DELETE FROM gncontr
        WHERE ROWID = r1.ROWID;
    EXCEPTION 
      WHEN OTHERS THEN
        dbms_output.put_line('Falha ao deletar na tabela gncontr ' ||SQLERRM);
    END;
  END LOOP;
  
  COMMIT;
  dbms_output.put_line('Fim do processamento');
END;        
