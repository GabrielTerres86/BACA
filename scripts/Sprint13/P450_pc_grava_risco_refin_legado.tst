PL/SQL Developer Test script 3.0
108
-- Created on 02/07/2018 by T0031670 
declare 
  -- Local variables here
  qtd_dias  integer;
  dt_risco_refin DATE;
  vr_contador INTEGER;
  
  CURSOR cr_coops IS
    SELECT cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
     ORDER BY cdcooper ;  
  rw_coops cr_coops%ROWTYPE;
  
  CURSOR cr_emprest (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT w.cdcooper, w.nrdconta, w.nrctremp, w.dtdpagto,e.dtmvtolt,w.dsnivori
          ,DECODE(NVL(w.dsnivori,'A'),'A',0,'B',15,'C',31,'D',61,'E',91,'F',121,'G',151,'H',181,'HH',181) QTD_DIAS
          ,e.rowid
      FROM crawepr w, crapepr e
     WHERE e.cdcooper = w.cdcooper
       AND e.nrdconta = w.nrdconta
       AND e.nrctremp = w.nrctremp
       AND w.cdcooper = pr_cdcooper
       AND e.inliquid = 0
       AND e.inprejuz = 0
       AND (w.nrctrliq##1  > 0 OR
            w.nrliquid > 0)
       AND DTINICIO_ATRASO_REFIN IS NULL
     ORDER BY e.dtmvtolt;
  rw_emprest cr_emprest%ROWTYPE;

begin

  FOR rw_coops in cr_coops  LOOP

    vr_contador := 0;

    FOR rw_emprest in cr_emprest (pr_cdcooper => rw_coops.cdcooper ) LOOP

      IF rw_emprest.dtmvtolt <= '24/04/2018' THEN
        dt_risco_refin := rw_emprest.dtdpagto; 
        qtd_dias := 0;
      ELSE
        dt_risco_refin := rw_emprest.dtmvtolt - rw_emprest.QTD_DIAS;
        qtd_dias := rw_emprest.QTD_DIAS;
      END IF;

      vr_contador := vr_contador + 1;
      UPDATE crapepr SET DTINICIO_ATRASO_REFIN = dt_risco_refin
                        ,QTDIAS_ATRASO_REFIN   = qtd_dias
                        ,inrisco_refin         = NULL
                   WHERE ROWID = rw_emprest.Rowid;
    END LOOP;
    COMMIT;

  END LOOP;

end;
0
0
