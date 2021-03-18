DECLARE
  CURSOR cr_craplcm IS
    SELECT lcm.cdcooper
      , lcm.nrdconta
      , lau2.idlancto
      , lau2.dtmvtopg
      , lau2.nrcrcard
      , lau2.insitlau insitlau2
      , lcm.nrdocmto
      , lcm.dtrefere
    from craplcm lcm
    join craphis his on lcm.cdhistor = his.cdhistor
                        and lcm.cdcooper = his.cdcooper
    left join craplau lau on lcm.cdcooper     = lau.cdcooper
                             and lcm.nrdconta = lau.nrdconta
                             and lcm.nrdocmto = to_number(substr(lau.nrcrcard, -6))
                             and trunc(lcm.dtrefere) = trunc(nvl(lau.dtdebito, sysdate))

    left join craplau lau2 on lcm.cdcooper     = lau2.cdcooper
                             and lcm.nrdconta = lau2.nrdconta
                             and lcm.nrdocmto = to_number(substr(lau2.nrcrcard, -6))
                             -- de acordo com o script da procedure PC_CRPS277, a data que vai na dtdebito é a DTMVTOLT da LCM.
                             -- Não consegui validar a alteração no script pois o ambiente individual foi atualizado e não tenho mais registros
                             --   com a LAU.dtdebito preenchida na minha base.
                             -- and trunc(lcm.dtrefere) = trunc(nvl(lau.dtdebito, sysdate))
                             and trunc(lcm.dtmvtolt) = trunc(nvl(lau.dtdebito, sysdate))

    where lcm.cdhistor = 658
      -- Não existe uma referência na LAU com base na dtdebito
      and lau.nrdconta is  null
      -- Mas o lançamento feito na CRAPLAN, tem que existir na CRAPLAU
      and lau2.nrdconta is not null
      AND TRUNC(LCM.DTMVTOLT) >= TO_DATE('01/01/2021', 'DD/MM/RRRR')
      
    order by lcm.cdcooper
      , lcm.nrdconta
      , lcm.dtrefere;
  --
  rg_craplcm cr_craplcm%rowtype;
  --
  vr_total number;
  --
BEGIN
  --
  vr_total := 0;
  --
  OPEN cr_craplcm;
  --
  LOOP
    FETCH cr_craplcm into rg_craplcm;
    EXIT WHEN cr_craplcm%NOTFOUND;
    --
    update craplau
      set insitlau = 2
        , dtdebito = rg_craplcm.dtrefere
    WHERE idlancto = rg_craplcm.idlancto;
    --
    vr_total := vr_total + SQL%ROWCOUNT;
    --
    COMMIT;
    --
  END LOOP;
  --
  DBMS_OUTPUT.PUT_LINE('Total de registros alterados: ' || vr_total);
  --
  CLOSE cr_craplcm;
  --
EXCEPTION 
  WHEN OTHERS THEN
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar o script: ' || SQLERRM);
    --
END;
