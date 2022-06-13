declare 
  
   TYPE dados_typ IS RECORD(
      cdcooper cecred.crapcop.cdcooper%TYPE,
      nrdconta cecred.crapass.nrdconta%TYPE,
      nrctremp cecred.craplem.nrctremp%TYPE);
  
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados          t_dados_tab := t_dados_tab();

BEGIN
    v_dados.extend();
    v_dados(v_dados.last()).cdcooper := 1;
    v_dados(v_dados.last()).nrdconta := 9458603;
    v_dados(v_dados.last()).nrctremp := 2378766;
    
    v_dados.extend();
    v_dados(v_dados.last()).cdcooper := 1;
    v_dados(v_dados.last()).nrdconta := 9742212;
    v_dados(v_dados.last()).nrctremp := 2355183;
    
    v_dados.extend();
    v_dados(v_dados.last()).cdcooper := 14;
    v_dados(v_dados.last()).nrdconta := 253847;
    v_dados(v_dados.last()).nrctremp := 26295;
    
    v_dados.extend();
    v_dados(v_dados.last()).cdcooper := 14;
    v_dados(v_dados.last()).nrdconta := 253863;
    v_dados(v_dados.last()).nrctremp := 26278;
    
    FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP

      UPDATE crapepr c
         SET diarefju = 31,
             mesrefju = 5
       WHERE c.cdcooper = v_dados(x).cdcooper
         AND c.nrdconta = v_dados(x).nrdconta
         AND c.nrctremp = v_dados(x).nrctremp;
    END LOOP;
    COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
