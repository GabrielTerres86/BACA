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
    v_dados(v_dados.last()).nrdconta := 9630520;
    v_dados(v_dados.last()).nrctremp := 2344916;
    
    v_dados.extend();
    v_dados(v_dados.last()).cdcooper := 1;
    v_dados(v_dados.last()).nrdconta := 8807680;
    v_dados(v_dados.last()).nrctremp := 2325890;
    
    v_dados.extend();
    v_dados(v_dados.last()).cdcooper := 1;
    v_dados(v_dados.last()).nrdconta := 9788425;
    v_dados(v_dados.last()).nrctremp := 2321504;
    
    v_dados.extend();
    v_dados(v_dados.last()).cdcooper := 1;
    v_dados(v_dados.last()).nrdconta := 10400630;
    v_dados(v_dados.last()).nrctremp := 2298701;
    
    v_dados.extend();
    v_dados(v_dados.last()).cdcooper := 16;
    v_dados(v_dados.last()).nrdconta := 457191;
    v_dados(v_dados.last()).nrctremp := 151321;
    
    FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP

      UPDATE cecred.crapepr c
         SET diarefju = 28,
             mesrefju = 2
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
