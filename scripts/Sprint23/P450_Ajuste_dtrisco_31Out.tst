PL/SQL Developer Test script 3.0
97
-- Created on 19/11/2018 by T0031670 
declare 
  -- Local variables here
  vr_contador integer;
  
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
   ORDER BY cdcooper DESC;  
  
  CURSOR cr_contas (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT r.cdcooper, r.dtrefere, r.nrdconta, r.nrctremp
         , r.cdmodali, r.nrseqctr, r.inddocto
          ,r.innivris,r.nrdgrupo
        ,(SELECT decode(MAX(x.innivris),10,9,MAX(x.innivris))
            FROM crapris x
          WHERE x.cdcooper = r.cdcooper 
            AND x.dtrefere = r.dtrefere
            AND x.nrdconta = r.nrdconta) inrisco_novo
        ,(SELECT MIN(x.nrdgrupo)
            FROM crapris x
          WHERE x.cdcooper = r.cdcooper 
            AND x.dtrefere = r.dtrefere
            AND x.nrdconta = r.nrdconta) nrgrupo_novo
    FROM crapris r
   WHERE r.cdcooper = pr_cdcooper
     AND r.dtrefere = to_date('31/10/2018','DD/MM/YYYY')
     AND r.cdmodali IN(101,201,1901)
     AND r.inddocto NOT IN(4,5)
     AND r.dtdrisco IS NULL;

BEGIN


/*  dbms_output.put_line('Cooper'     
                    || ';Conta'     
                    || ';Contrato'  
                    || ';Modali'    
                    || ';Indocto'   
                    || ';RIS Antes' 
                    || ';RIS Depois'
                    || ';GRP Antes' 
                    || ';GRP Depois');*/

  FOR rw_cop IN cr_cop LOOP

    vr_contador := 0;
    dbms_output.put_line('COOP: ' || rw_cop.cdcooper || ' - Inicio');

    FOR rw_contas IN cr_contas (pr_cdcooper => rw_cop.cdcooper) LOOP
      vr_contador := vr_contador + 1;  

      -- Atualiza crapRIS      
      UPDATE crapris r
         SET r.dtdrisco = to_date('31/10/2018','DD/MM/YYYY')
            ,r.innivris = rw_contas.inrisco_novo
            ,r.nrdgrupo = rw_contas.nrgrupo_novo
       WHERE r.cdcooper = rw_contas.cdcooper
         AND r.dtrefere = to_date('31/10/2018','DD/MM/YYYY')
         AND r.nrdconta = rw_contas.nrdconta
         AND r.nrctremp = rw_contas.nrctremp
         AND r.cdmodali = rw_contas.cdmodali
         AND r.inddocto = rw_contas.inddocto;

      --CDCOOPER, DTREFERE, NRDCONTA, INNIVRIS, CDMODALI, NRCTREMP, NRSEQCTR
      UPDATE crapvri r
         SET r.innivris = rw_contas.inrisco_novo
       WHERE r.cdcooper = rw_contas.cdcooper
         AND r.dtrefere = to_date('31/10/2018','DD/MM/YYYY')
         AND r.nrdconta = rw_contas.nrdconta
         AND r.cdmodali = rw_contas.cdmodali
         AND r.nrctremp = rw_contas.nrctremp
         AND r.nrseqctr = rw_contas.nrseqctr;

/*
      dbms_output.put_line(rw_contas.cdcooper 
                        || ';' || rw_contas.nrdconta 
                        || ';' || rw_contas.nrctremp
                        || ';' || rw_contas.cdmodali
                        || ';' || rw_contas.inddocto
                        || ';' || rw_contas.innivris  
                        || ';' || rw_contas.inrisco_novo
                        || ';' || rw_contas.nrdgrupo
                        || ';' || rw_contas.nrgrupo_novo);
*/
      -- COMMIT A CADA 1000
      IF (vr_contador MOD 1000) = 0 THEN
        COMMIT;
      END IF;
    
    END LOOP;  
    dbms_output.put_line('COOP: ' || rw_cop.cdcooper || ' - Fim => '|| vr_contador);
    COMMIT;
  END LOOP;  
--  ROLLBACK;
end;
0
0
