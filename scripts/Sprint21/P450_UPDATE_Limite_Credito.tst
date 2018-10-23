PL/SQL Developer Test script 3.0
72
-- Created on 17/10/2018 by T0031670 
declare 
  -- Local variables here
  vr_cont      integer;
  vr_seqarqv   INTEGER:=1;
  
  vr_nmarquiv  VARCHAR2(300);
  vr_des_msg   VARCHAR2(1000);
  w_cdcritic   crapcri.cdcritic%TYPE;
  w_dscritic   varchar2(3000);
    
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
     ORDER BY cdcooper;
  rw_cop cr_cop%ROWTYPE;

  CURSOR cr_max_refere (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT MAX(dtrefere) dtrefere
      FROM crapris r
     WHERE r.cdcooper = pr_cdcooper;
  rw_max_refere cr_max_refere%ROWTYPE;

  CURSOR cr_sql (pr_cdcooper IN crapcop.cdcooper%TYPE
                ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
    SELECT x.innivris
          ,DECODE(x.dtdrisco,NULL,x.dtrefere,x.dtdrisco) dtdrisco
          ,x.cdcooper
          ,x.dtrefere
          ,x.nrdconta
      FROM (
            SELECT cdcooper,nrdconta,r.dtrefere,MAX(innivris) innivris, MAX(dtdrisco) dtdrisco
              FROM crapris r
             WHERE r.cdcooper = pr_cdcooper
               AND r.dtrefere = pr_dtrefere
               AND r.cdorigem = 1
             GROUP BY r.cdcooper,r.dtrefere,nrdconta
           )x;
  rw_sql cr_sql%ROWTYPE;

begin
  -- Test statements here
  FOR rw_cop IN cr_cop LOOP

    vr_cont    := 0;

    OPEN cr_max_refere (rw_cop.cdcooper);
    FETCH cr_max_refere INTO rw_max_refere;
    CLOSE cr_max_refere;

    FOR rw_sql IN cr_sql (pr_cdcooper => rw_cop.cdcooper
                         ,pr_dtrefere => rw_max_refere.dtrefere) LOOP

      vr_cont := vr_cont + 1;

      UPDATE crapris
         SET innivris = rw_sql.innivris
            ,dtdrisco = rw_sql.dtdrisco
       WHERE cdcooper = rw_sql.cdcooper
         AND dtrefere = rw_sql.dtrefere
         AND nrdconta = rw_sql.nrdconta
         AND cdmodali = 1901;

      IF MOD(vr_cont,10000) = 0 THEN
        COMMIT; -- A cada 10.000 registros
      END IF;        
    END LOOP;
    COMMIT; -- Por cooperativa
  END LOOP;
  
end;
0
0
