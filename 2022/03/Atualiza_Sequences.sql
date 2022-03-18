DECLARE

  vr_limite_tituloleg NUMBER(20);
  vr_limite_opleg     NUMBER(20);
  vr_number           NUMBER(20);

BEGIN

  SELECT MAX(to_number("IdTituloLeg"))
         ,MAX(to_number("IdOpLeg"))
    INTO vr_limite_tituloleg
        ,vr_limite_opleg
    FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql
   WHERE "CdLeg" = 'LEG'
     AND "ISPBAdministrado" = 5463212;

  vr_limite_opleg := vr_limite_opleg + 10000;

  vr_number := 0;

  LOOP
  
    EXIT WHEN vr_number > vr_limite_tituloleg;
  
    SELECT seqcob_idtitleg.NEXTVAL
      INTO vr_number
      FROM dual;
  
  END LOOP;

  vr_number := 0;

  LOOP
  
    EXIT WHEN vr_number > vr_limite_opleg;
  
    SELECT seqcob_idopeleg.NEXTVAL
      INTO vr_number
      FROM dual;
  
  END LOOP;

  COMMIT;
END;
