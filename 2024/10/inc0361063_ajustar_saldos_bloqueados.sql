DECLARE 

  CURSOR cr_saldo IS
    SELECT a.cdcooper
         , a.nrdconta
         , a.cdhistor
         , h.inhistor
         , sum(a.vllanmto) vllanmto
      FROM cecred.craphis h 
         , cecred.crapdpb a
     WHERE a.cdcooper = 13
       AND a.dtliblan = to_date('25/09/2024','dd/mm/yyyy')
       AND a.cdcooper = h.cdcooper
       AND a.cdhistor = h.cdhistor
       AND a.inlibera = 1
     GROUP BY a.cdcooper
         , a.nrdconta
         , a.cdhistor
         , h.inhistor
     ORDER BY a.cdcooper
         , a.nrdconta
         , a.cdhistor;
         
BEGIN
  
  FOR lanc IN cr_saldo LOOP
    
    BEGIN
      IF lanc.inhistor = 3 THEN
        UPDATE crapsld t 
           SET t.vlsdbloq = t.vlsdbloq + lanc.vllanmto
             , t.vlsddisp = t.vlsddisp - lanc.vllanmto
         WHERE t.cdcooper = lanc.cdcooper
           AND t.nrdconta = lanc.nrdconta;
      ELSIF lanc.inhistor = 4 THEN
        UPDATE crapsld t 
           SET t.vlsdblpr = t.vlsdblpr + lanc.vllanmto
             , t.vlsddisp = t.vlsddisp - lanc.vllanmto
         WHERE t.cdcooper = lanc.cdcooper
           AND t.nrdconta = lanc.nrdconta;
      ELSIF lanc.inhistor = 5 THEN
        UPDATE crapsld t 
           SET t.vlsdblfp = t.vlsdblfp + lanc.vllanmto
             , t.vlsddisp = t.vlsddisp - lanc.vllanmto
         WHERE t.cdcooper = lanc.cdcooper
           AND t.nrdconta = lanc.nrdconta;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20000,'Erro ao atualizar conta('||lanc.nrdconta||'): '||SQLERRM);
    END;
    
  END LOOP;
  
  COMMIT;
  
END;
