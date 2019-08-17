DECLARE
  CURSOR cr_cdcooper IS
    SELECT c.cdcooper
         , x.dtmvtolt
      FROM crapdat x
         , crapcop c
     WHERE x.cdcooper = c.cdcooper
       AND c.flgativo = 1;

  CURSOR cr_cdbccxlt IS
    SELECT 11 cdbccxlt
      FROM dual
    UNION
    SELECT 85
      FROM dual
    UNION
    SELECT 100
      FROM dual;
  
  CURSOR cr_cdagenci(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT c.cdagenci
      FROM crapage c
     WHERE c.cdcooper = pr_cdcooper;

  CURSOR cr_nrdolote IS
    SELECT 11900 nrdolote FROM dual UNION
    SELECT 16900 FROM dual UNION
    SELECT 15900 FROM dual UNION
    SELECT 17900 FROM dual UNION
    SELECT 23900 FROM dual UNION
    SELECT 7050 FROM dual UNION
    SELECT 6400 FROM dual UNION
    SELECT 10105 FROM dual UNION
    SELECT 10104 FROM dual UNION
    SELECT 10106 FROM dual UNION
    SELECT 8473 FROM dual UNION
    SELECT 8383 FROM dual UNION
    SELECT 8384 FROM dual UNION
    SELECT 8470 FROM dual UNION
    SELECT 10115 FROM dual UNION
    SELECT 10200 FROM dual UNION
    SELECT 17000 FROM dual UNION
    SELECT 16000 FROM dual UNION
    SELECT 10800 FROM dual UNION
    SELECT 11000 FROM dual UNION
    SELECT 15000 FROM dual UNION
    SELECT 23000 FROM dual;
  
  vr_dschave  VARCHAR2(1000);
  vr_contador NUMBER(15) := 0;
  vr_insert NUMBER(15) := 0;
  vr_update NUMBER(15) := 0;
BEGIN
  dbms_output.enable(1000000000);

  FOR rw_cdcooper IN cr_cdcooper LOOP
    FOR rw_cdagenci IN cr_cdagenci(rw_cdcooper.cdcooper) LOOP
      FOR rw_cdbccxlt IN cr_cdbccxlt LOOP
        FOR rw_nrdolote IN cr_nrdolote LOOP
          FOR i IN 0..30 LOOP
            vr_dschave := rw_cdcooper.cdcooper||';'
                        ||to_char((rw_cdcooper.dtmvtolt + i),'DD/MM/RRRR')||';'
                        ||rw_cdagenci.cdagenci||';'
                        ||rw_cdbccxlt.cdbccxlt||';'
                        ||rw_nrdolote.nrdolote;
            
            begin
              insert into crapsqu(nmtabela, nmdcampo, dsdchave, nrseqatu) values ('CRAPLOT', 'NRSEQDIG', vr_dschave, 10000000);
              vr_insert := vr_insert + 1;
            exception
              when dup_val_on_index then
                update crapsqu c
                   set c.nrseqatu = c.nrseqatu + 10000000
                 where upper(c.nmtabela) = 'CRAPLOT'
                   and upper(c.nmdcampo) = 'NRSEQDIG'
                   and upper(c.dsdchave) = vr_dschave;

                vr_update := vr_update + 1;
              when others then
                dbms_output.put_line('Erro - '||vr_dschave||' - '||sqlerrm);
            end;

            vr_contador := vr_contador + 1;
            
            IF rw_nrdolote.nrdolote IN (17000,16000,10800,11000,15000,23000) THEN
              FOR x IN 1..99 LOOP
                vr_dschave := rw_cdcooper.cdcooper||';'
                            ||to_char((rw_cdcooper.dtmvtolt + i),'DD/MM/RRRR')||';'
                            ||rw_cdagenci.cdagenci||';'
                            ||rw_cdbccxlt.cdbccxlt||';'
                            ||(rw_nrdolote.nrdolote + x);
                
                begin
                  insert into crapsqu(nmtabela, nmdcampo, dsdchave, nrseqatu) values ('CRAPLOT', 'NRSEQDIG', vr_dschave, 10000000);
                  vr_insert := vr_insert + 1;
                exception
                  when dup_val_on_index then
                    update crapsqu c
                       set c.nrseqatu = c.nrseqatu + 10000000
                     where upper(c.nmtabela) = 'CRAPLOT'
                       and upper(c.nmdcampo) = 'NRSEQDIG'
                       and upper(c.dsdchave) = vr_dschave;

                    vr_update := vr_update + 1;
                  when others then
                    dbms_output.put_line('Erro - '||vr_dschave||' - '||sqlerrm);
                end;

                vr_contador := vr_contador + 1;
              END LOOP;
            END IF;
          END LOOP;

          COMMIT;
        END LOOP;
      END LOOP;
    END LOOP;
  END LOOP;
  
  dbms_output.put_line('Total : '||vr_contador);
  dbms_output.put_line('Insert: '||vr_insert);
  dbms_output.put_line('Update: '||vr_update);
END;
