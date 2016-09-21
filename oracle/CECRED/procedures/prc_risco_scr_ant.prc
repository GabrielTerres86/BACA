CREATE OR REPLACE PROCEDURE CECRED.prc_risco_scr_ant IS

  aux_cdcooper_old crapass.cdcooper%TYPE := 15;
  aux_cdcooper_new crapass.cdcooper%TYPE := 13;
  aux_data_ate     DATE := to_date('30/09/2014','dd/mm/yyyy');
  aux_count        NUMBER(10) := 0;
  aux_count2       NUMBER(10) := 0;

  CURSOR cur_crapris IS
    SELECT crapris.*
          ,craptco.cdcooper new_cdcooper
          ,craptco.nrdconta new_nrdconta
      FROM craptco
          ,crapris
     WHERE craptco.cdcopant = crapris.cdcooper
       AND craptco.nrctaant = crapris.nrdconta
       AND craptco.cdcopant = aux_cdcooper_old
       AND craptco.cdcooper = aux_cdcooper_new
       AND TRUNC(crapris.dtrefere) <= TRUNC(last_day(aux_data_ate))
       AND TRUNC(crapris.dtrefere) = TRUNC(last_day(crapris.dtrefere)); -- Apenas para garantir que rode apenas se for último dia do mês

  CURSOR cur_crapvri(p_cdcooper crapris.cdcooper%TYPE
                    ,p_dtrefere crapris.dtrefere%TYPE
                    ,p_nrdconta crapris.nrdconta%TYPE
                    ,p_innivris crapris.innivris%TYPE
                    ,p_cdmodali crapris.cdmodali%TYPE
                    ,p_nrctremp crapris.nrctremp%TYPE
                    ,p_nrseqctr crapris.nrseqctr%TYPE) IS
    SELECT crapvri.*
      FROM crapvri
     WHERE crapvri.cdcooper = p_cdcooper
       AND crapvri.dtrefere = p_dtrefere
       AND crapvri.nrdconta = p_nrdconta
       AND crapvri.innivris = p_innivris
       AND crapvri.cdmodali = p_cdmodali
       AND crapvri.nrctremp = p_nrctremp
       AND crapvri.nrseqctr = p_nrseqctr;

BEGIN



  FOR reg_crapris IN cur_crapris LOOP

    BEGIN
      INSERT INTO crapris
        (cdcooper
        ,nrdconta
        ,dtrefere
        ,innivris
        ,qtdiaatr
        ,vldivida
        ,vlvec180
        ,vlvec360
        ,vlvec999
        ,vldiv060
        ,vldiv180
        ,vldiv360
        ,vldiv999
        ,vlprjano
        ,vlprjaan
        ,inpessoa
        ,nrcpfcgc
        ,vlprjant
        ,inddocto
        ,cdmodali
        ,nrctremp
        ,nrseqctr
        ,dtinictr
        ,cdorigem
        ,cdagenci
        ,innivori
        ,vlprjm60
        ,dtdrisco
        ,qtdriclq
        ,nrdgrupo
        ,vljura60
        ,inindris
        ,cdinfadi
        ,nrctrnov
        ,flgindiv
        ,dtprxpar
        ,dsinfaux
        ,vlprxpar
        ,qtparcel)
      VALUES
        (reg_crapris.new_cdcooper
        ,reg_crapris.new_nrdconta
        ,reg_crapris.dtrefere
        ,reg_crapris.innivris
        ,reg_crapris.qtdiaatr
        ,reg_crapris.vldivida
        ,reg_crapris.vlvec180
        ,reg_crapris.vlvec360
        ,reg_crapris.vlvec999
        ,reg_crapris.vldiv060
        ,reg_crapris.vldiv180
        ,reg_crapris.vldiv360
        ,reg_crapris.vldiv999
        ,reg_crapris.vlprjano
        ,reg_crapris.vlprjaan
        ,reg_crapris.inpessoa
        ,reg_crapris.nrcpfcgc
        ,reg_crapris.vlprjant
        ,reg_crapris.inddocto
        ,reg_crapris.cdmodali
        ,reg_crapris.nrctremp
        ,reg_crapris.nrseqctr
        ,reg_crapris.dtinictr
        ,reg_crapris.cdorigem
        ,reg_crapris.cdagenci
        ,reg_crapris.innivori
        ,reg_crapris.vlprjm60
        ,reg_crapris.dtdrisco
        ,reg_crapris.qtdriclq
        ,reg_crapris.nrdgrupo
        ,reg_crapris.vljura60
        ,reg_crapris.inindris
        ,reg_crapris.cdinfadi
        ,reg_crapris.nrctrnov
        ,reg_crapris.flgindiv
        ,reg_crapris.dtprxpar
        ,reg_crapris.dsinfaux
        ,reg_crapris.vlprxpar
        ,reg_crapris.qtparcel);

    aux_count := aux_count+1;

    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
    END;

    FOR reg_crapvri IN cur_crapvri(reg_crapris.cdcooper, reg_crapris.dtrefere, reg_crapris.nrdconta, reg_crapris.innivris, reg_crapris.cdmodali, reg_crapris.nrctremp, reg_crapris.nrseqctr) LOOP

      BEGIN
        INSERT INTO crapvri
          (cdcooper
          ,nrdconta
          ,dtrefere
          ,innivris
          ,cdmodali
          ,nrctremp
          ,nrseqctr
          ,cdvencto
          ,vldivida)
        VALUES
          (reg_crapris.new_cdcooper
          ,reg_crapris.new_nrdconta
          ,reg_crapvri.dtrefere
          ,reg_crapvri.innivris
          ,reg_crapvri.cdmodali
          ,reg_crapvri.nrctremp
          ,reg_crapvri.nrseqctr
          ,reg_crapvri.cdvencto
          ,reg_crapvri.vldivida);

      aux_count2 := aux_count2+1;

      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL;
      END;
    END LOOP;
  END LOOP;

  dbms_output.put_line('Registros crapris processados: ' || aux_count);
  dbms_output.put_line('Registros crapvri processados: ' || aux_count2);
commit;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('ERRO: ' || SQLERRM);
END prc_risco_scr_ant;
/

