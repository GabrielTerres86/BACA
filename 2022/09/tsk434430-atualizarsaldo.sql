DECLARE
  TYPE dados_typ IS RECORD(
      vr_cdcooper cecred.crapcop.cdcooper%TYPE,
      vr_nrdconta cecred.crapass.nrdconta%TYPE,
      vr_nrctremp cecred.craplem.nrctremp%TYPE,
      vr_vllanmto cecred.craplem.vllanmto%TYPE);
  
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados          t_dados_tab := t_dados_tab();
  
BEGIN
    
    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9171550;
    v_dados(v_dados.last()).vr_nrctremp := 2412155;
    v_dados(v_dados.last()).vr_vllanmto := -2414.53;
    
    FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP
      UPDATE CECRED.CRAPEPR
         SET vlprejuz = vlprejuz + v_dados(x).vr_vllanmto,
             vlsdprej = vlsdprej + v_dados(x).vr_vllanmto
       WHERE CDCOOPER = v_dados(x).vr_cdcooper
         AND NRDCONTA = v_dados(x).vr_nrdconta
         AND NRCTREMP = v_dados(x).vr_nrctremp;
         
    END LOOP;
    
    COMMIT;
    
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
