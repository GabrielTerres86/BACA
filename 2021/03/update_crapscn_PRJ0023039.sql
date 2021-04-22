rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
/*

      Script de ajuste convênios TIVIT para habilitar formas de arrecadação exceto débito automático.
      
      Daniel Lombardi (Mout'S)

*/
DECLARE 
  
  CURSOR cr_registros IS
    SELECT DISTINCT scn.cdempres
    FROM crapscn scn
        ,crapcon con 
    WHERE scn.cdempcon = con.cdempcon
      AND TRIM(scn.Cdsegmto) = to_char(con.cdsegmto)
      AND con.cdhistor = 3361;
  rw_registros cr_registros%ROWTYPE;
  
BEGIN

  FOR rw_registros IN cr_registros LOOP
    
    UPDATE crapscn 
       SET crapscn.dsoparre = 'ABCDF'
    WHERE crapscn.cdempres = rw_registros.cdempres;
    
  END LOOP;
  COMMIT;  
  
END;
/
