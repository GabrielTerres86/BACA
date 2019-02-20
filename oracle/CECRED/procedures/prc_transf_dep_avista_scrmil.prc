CREATE OR REPLACE PROCEDURE CECRED.prc_transf_dep_avista_scrmil IS

  aux_cdcooper_old crapass.cdcooper%TYPE := 15;
  aux_cdcooper_new crapass.cdcooper%TYPE := 13;
  aux_caminho      VARCHAR2(400) := '/micros/cecred/james/credimilsul/';
  aux_dados        CLOB; -- Dados do arquivo
  aux_linha        VARCHAR(1000);
  aux_conf_index   NUMBER := 0;
  aux_vlformat     VARCHAR2(50) := '9999999999999999999990D00';
  vr_dscritic      VARCHAR2(1000);
  exc_erro         EXCEPTION;

  aux_vlsdposi   crapsld.vlsddisp%TYPE;
  aux_vlsdnega   crapsld.vlsddisp%TYPE;
  aux_vlsddisp   crapsld.vlsddisp%TYPE;
  
  aux_age_anterior       crapsld.vlsddisp%TYPE := 0;
  aux_tot_age_count      NUMBER(15);
  aux_tot_age_vlsddisp   crapsld.vlsddisp%TYPE := 0;
  aux_tot_age_vlsdbloq   crapsld.vlsdbloq%TYPE := 0;
  aux_tot_age_vlsdblpr   crapsld.vlsdblpr%TYPE := 0;
  aux_tot_age_vlsdblfp   crapsld.vlsdblfp%TYPE := 0;
  aux_tot_age_vlsdchsl   crapsld.vlsdchsl%TYPE := 0;
  aux_tot_age_vliofmes   crapsld.vliofmes%TYPE := 0;
  aux_tot_age_vlsldtra   crapsld.vlsddisp%TYPE := 0;
  aux_tot_age_vlsdposi   crapsld.vlsddisp%TYPE := 0;
  aux_tot_age_vlsdnega   crapsld.vlsddisp%TYPE := 0;
  
  aux_tot_count      NUMBER(15);
  aux_tot_vlsddisp   crapsld.vlsddisp%TYPE := 0;
  aux_tot_vlsdbloq   crapsld.vlsdbloq%TYPE := 0;
  aux_tot_vlsdblpr   crapsld.vlsdblpr%TYPE := 0;
  aux_tot_vlsdblfp   crapsld.vlsdblfp%TYPE := 0;
  aux_tot_vlsdchsl   crapsld.vlsdchsl%TYPE := 0;
  aux_tot_vliofmes   crapsld.vliofmes%TYPE := 0;
  aux_tot_vlsldtra   crapsld.vlsddisp%TYPE := 0;
  aux_tot_vlsdposi   crapsld.vlsddisp%TYPE := 0;
  aux_tot_vlsdnega   crapsld.vlsddisp%TYPE := 0;

  TYPE r_conferencia IS RECORD(
     cdagenci crapass.cdagenci%TYPE
    ,nrdconta crapass.nrdconta%TYPE
    ,vlsddisp crapsld.vlsddisp%TYPE
    ,vlsdbloq crapsld.vlsdbloq%TYPE
    ,vlsdblpr crapsld.vlsdblpr%TYPE
    ,vlsdblfp crapsld.vlsdblfp%TYPE
    ,vlsdchsl crapsld.vlsdchsl%TYPE
    ,vliofmes crapsld.vliofmes%TYPE
    ,vlsldtra crapsld.vlsddisp%TYPE
    ,nrctavia craptco.nrdconta%TYPE
    ,vlsdposi crapsld.vlsddisp%TYPE
    ,vlsdnega crapsld.vlsddisp%TYPE);
  TYPE type_conferencia IS TABLE OF r_conferencia INDEX BY PLS_INTEGER;

  tt_conferencia type_conferencia;

  CURSOR cur_crapass IS
    SELECT crapass.*
          ,craptco.cdcooper new_cdcooper
          ,craptco.nrdconta new_nrdconta
      FROM craptco
          ,crapass
     WHERE crapass.cdcooper = craptco.cdcopant
       AND crapass.nrdconta = craptco.nrctaant
       AND craptco.cdcopant = aux_cdcooper_old
       AND craptco.cdcooper = aux_cdcooper_new
     ORDER BY crapass.cdcooper
             ,crapass.cdagenci
             ,crapass.nrdconta;
  -- AND craptco.cdageant IN (1, 2)

  -- Saldos Deposito a Vista
  CURSOR cur_crapsld(p_cdcooper crapsld.cdcooper%TYPE
                    ,p_nrdconta crapsld.nrdconta%TYPE) IS
    SELECT crapsld.*
      FROM crapsld
     WHERE crapsld.cdcooper = p_cdcooper
       AND crapsld.nrdconta = p_nrdconta;

  -- Saldos Diarios
  CURSOR cur_crapsda(p_cdcooper crapsda.cdcooper%TYPE
                    ,p_nrdconta crapsda.nrdconta%TYPE) IS
    SELECT crapsda.*
      FROM crapsda
     WHERE crapsda.cdcooper = p_cdcooper
       AND crapsda.nrdconta = p_nrdconta;

  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE prc_escreve_clob(pr_des_dados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(aux_dados, length(pr_des_dados), pr_des_dados);
  END;
  
  PROCEDURE prc_escreve_totais_agencia IS
  BEGIN        
        aux_linha := chr(13) || chr(10);
        aux_linha := aux_linha || ',,,,,,,,';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vlsdposi, aux_vlformat)) || '"';
        
        prc_escreve_clob(aux_linha);
        
        aux_linha := chr(13) || chr(10);
        aux_linha := aux_linha || ',,,,,,,,';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vlsdnega, aux_vlformat)) || '"';
        
        prc_escreve_clob(aux_linha);
        
        aux_linha := chr(13) || chr(10);
        aux_linha := aux_linha || 'Total PA,';
        aux_linha := aux_linha || aux_tot_age_count || ',';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vlsddisp, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vlsdbloq, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vlsdblpr, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vlsdblfp, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vlsdchsl, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vliofmes, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_age_vlsldtra, aux_vlformat)) || '"';
        
        prc_escreve_clob(aux_linha);
        
        aux_linha := chr(13) || chr(10);
        prc_escreve_clob(aux_linha);
        
        aux_tot_age_vlsddisp := 0;
        aux_tot_age_vlsdbloq := 0;
        aux_tot_age_vlsdblpr := 0;
        aux_tot_age_vlsdblfp := 0;
        aux_tot_age_vlsdchsl := 0;
        aux_tot_age_vliofmes := 0;
        aux_tot_age_vlsldtra := 0;
        aux_tot_age_vlsdposi := 0;
        aux_tot_age_vlsdnega := 0;
  END;
  
  PROCEDURE prc_escreve_totais_geral IS
  BEGIN
        aux_linha := chr(13) || chr(10);
        aux_linha := aux_linha || ',,,,,,,,';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vlsdposi, aux_vlformat)) || '"';
        
        prc_escreve_clob(aux_linha);
        
        aux_linha := chr(13) || chr(10);
        aux_linha := aux_linha || ',,,,,,,,';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vlsdnega, aux_vlformat)) || '"';
        
        prc_escreve_clob(aux_linha);
        
        aux_linha := chr(13) || chr(10);
        aux_linha := aux_linha || 'Total Geral,';
        aux_linha := aux_linha || aux_tot_count || ',';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vlsddisp, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vlsdbloq, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vlsdblpr, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vlsdblfp, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vlsdchsl, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vliofmes, aux_vlformat)) || '",';
        aux_linha := aux_linha || '"' || TRIM(to_char(aux_tot_vlsldtra, aux_vlformat)) || '"';
        
        prc_escreve_clob(aux_linha);
        
        aux_linha := chr(13) || chr(10);
        prc_escreve_clob(aux_linha);
        
        aux_tot_vlsddisp := 0;
        aux_tot_vlsdbloq := 0;
        aux_tot_vlsdblpr := 0;
        aux_tot_vlsdblfp := 0;
        aux_tot_vlsdchsl := 0;
        aux_tot_vliofmes := 0;
        aux_tot_vlsldtra := 0;
        aux_tot_vlsdposi := 0;
        aux_tot_vlsdnega := 0;
  END;
  
BEGIN

  tt_conferencia.delete;

  FOR reg_crapass IN cur_crapass LOOP
  
    --Saldos Deposito a Vista
    BEGIN
      
      -- Apaga registro criado anteriormente na migracao cadastro
      DELETE FROM crapsld
       WHERE crapsld.cdcooper = reg_crapass.new_cdcooper
         AND crapsld.nrdconta = reg_crapass.new_nrdconta;
    
      FOR reg_crapsld IN cur_crapsld(reg_crapass.cdcooper, reg_crapass.nrdconta) LOOP
        -- Saldos bloqueados serão migrados como disponivel
        aux_vlsddisp := (reg_crapsld.vlsddisp + reg_crapsld.vlsdbloq +
                        reg_crapsld.vlsdblpr + reg_crapsld.vlsdblfp +
                        reg_crapsld.vlsdchsl);
      
        IF aux_vlsddisp < 0 THEN
          aux_vlsdnega := aux_vlsddisp;
          aux_vlsdposi := 0;
        ELSE
          aux_vlsdposi := aux_vlsddisp;
          aux_vlsdnega := 0;
        END IF;
      
        BEGIN
          INSERT INTO crapsld
            (cdcooper
            ,nrdconta
            ,vlsdbloq
            ,vlsdblpr
            ,vlsdblfp
            ,vlsdchsl
            ,vlsmpmes
            ,vlsmnmes
            ,vlsmnesp
            ,qtsmamfx
            ,vlsddisp
            ,qtjramfx
            ,qtlanano
            ,qtlanmes
            ,vljuresp
            ,vljurmes
            ,vlsdextr
            ,vlsdmesa
            ,vltsallq
            ,vlsmstre##1
            ,vlsmstre##2
            ,vlsmstre##3
            ,vlsmstre##4
            ,vlsmstre##5
            ,vlsmstre##6
            ,vltsalan
            ,qtddsdev
            ,dtdsdclq
            ,qtipamfx
            ,vlipmfpg
            ,vlipmfap
            ,vlbasipm
            ,vlsmnblq
            ,vljursaq
            ,qtddtdev
            ,vlsdexes
            ,dtsdexes
            ,vlsdanes
            ,dtsdanes
            ,vlbasiof
            ,vliofmes
            ,vltotcre##1
            ,vltotcre##2
            ,vltotcre##3
            ,vltotcre##4
            ,vltotcre##5
            ,vltotcre##6
            ,vltotcre##7
            ,vltotcre##8
            ,vltotcre##9
            ,vltotcre##10
            ,vltotcre##11
            ,vltotcre##12
            ,vlcremes
            ,qtddusol
            ,vlsdindi
            ,dtrefere
            ,dtrefext
            ,dtrisclq
            ,qtdriclq
            ,vldisext
            ,vldisant
            ,vlblqant
            ,vlblqext
            ,vlblpant
            ,vlblpext
            ,vlblfant
            ,vlblfext
            ,vlchsant
            ,vlchsext
            ,vlindant
            ,vlindext
            ,smposano##1
            ,smposano##2
            ,smposano##3
            ,smposano##4
            ,smposano##5
            ,smposano##6
            ,smposano##7
            ,smposano##8
            ,smposano##9
            ,smposano##10
            ,smposano##11
            ,smposano##12
            ,smposant##1
            ,smposant##2
            ,smposant##3
            ,smposant##4
            ,smposant##5
            ,smposant##6
            ,smposant##7
            ,smposant##8
            ,smposant##9
            ,smposant##10
            ,smposant##11
            ,smposant##12
            ,smnegano##1
            ,smnegano##2
            ,smnegano##3
            ,smnegano##4
            ,smnegano##5
            ,smnegano##6
            ,smnegano##7
            ,smnegano##8
            ,smnegano##9
            ,smnegano##10
            ,smnegano##11
            ,smnegano##12
            ,smnegant##1
            ,smnegant##2
            ,smnegant##3
            ,smnegant##4
            ,smnegant##5
            ,smnegant##6
            ,smnegant##7
            ,smnegant##8
            ,smnegant##9
            ,smnegant##10
            ,smnegant##11
            ,smnegant##12
            ,smblqano##1
            ,smblqano##2
            ,smblqano##3
            ,smblqano##4
            ,smblqano##5
            ,smblqano##6
            ,smblqano##7
            ,smblqano##8
            ,smblqano##9
            ,smblqano##10
            ,smblqano##11
            ,smblqano##12
            ,smblqant##1
            ,smblqant##2
            ,smblqant##3
            ,smblqant##4
            ,smblqant##5
            ,smblqant##6
            ,smblqant##7
            ,smblqant##8
            ,smblqant##9
            ,smblqant##10
            ,smblqant##11
            ,smblqant##12
            ,smespano##1
            ,smespano##2
            ,smespano##3
            ,smespano##4
            ,smespano##5
            ,smespano##6
            ,smespano##7
            ,smespano##8
            ,smespano##9
            ,smespano##10
            ,smespano##11
            ,smespano##12
            ,smespant##1
            ,smespant##2
            ,smespant##3
            ,smespant##4
            ,smespant##5
            ,smespant##6
            ,smespant##7
            ,smespant##8
            ,smespant##9
            ,smespant##10
            ,smespant##11
            ,smespant##12
            ,vlblqjud)
          VALUES
            (reg_crapass.new_cdcooper
            ,reg_crapass.new_nrdconta
            ,reg_crapsld.vlsdbloq
            ,reg_crapsld.vlsdblpr
            ,reg_crapsld.vlsdblfp
            ,reg_crapsld.vlsdchsl
            ,reg_crapsld.vlsmpmes
            ,reg_crapsld.vlsmnmes
            ,reg_crapsld.vlsmnesp
            ,reg_crapsld.qtsmamfx
            ,reg_crapsld.vlsddisp
            ,reg_crapsld.qtjramfx
            ,reg_crapsld.qtlanano
            ,reg_crapsld.qtlanmes
            ,reg_crapsld.vljuresp
            ,reg_crapsld.vljurmes
            ,reg_crapsld.vlsdextr
            ,reg_crapsld.vlsdmesa
            ,reg_crapsld.vltsallq
            ,reg_crapsld.vlsmstre##1
            ,reg_crapsld.vlsmstre##2
            ,reg_crapsld.vlsmstre##3
            ,reg_crapsld.vlsmstre##4
            ,reg_crapsld.vlsmstre##5
            ,reg_crapsld.vlsmstre##6
            ,reg_crapsld.vltsalan
            ,reg_crapsld.qtddsdev
            ,reg_crapsld.dtdsdclq
            ,reg_crapsld.qtipamfx
            ,reg_crapsld.vlipmfpg
            ,reg_crapsld.vlipmfap
            ,reg_crapsld.vlbasipm
            ,reg_crapsld.vlsmnblq
            ,reg_crapsld.vljursaq
            ,reg_crapsld.qtddtdev
            ,reg_crapsld.vlsdexes
            ,reg_crapsld.dtsdexes
            ,reg_crapsld.vlsdanes
            ,reg_crapsld.dtsdanes
            ,reg_crapsld.vlbasiof
            ,reg_crapsld.vliofmes
            ,reg_crapsld.vltotcre##1
            ,reg_crapsld.vltotcre##2
            ,reg_crapsld.vltotcre##3
            ,reg_crapsld.vltotcre##4
            ,reg_crapsld.vltotcre##5
            ,reg_crapsld.vltotcre##6
            ,reg_crapsld.vltotcre##7
            ,reg_crapsld.vltotcre##8
            ,reg_crapsld.vltotcre##9
            ,reg_crapsld.vltotcre##10
            ,reg_crapsld.vltotcre##11
            ,reg_crapsld.vltotcre##12
            ,reg_crapsld.vlcremes
            ,reg_crapsld.qtddusol
            ,reg_crapsld.vlsdindi
            ,reg_crapsld.dtrefere
            ,reg_crapsld.dtrefext
            ,reg_crapsld.dtrisclq
            ,reg_crapsld.qtdriclq
            ,reg_crapsld.vldisext
            ,reg_crapsld.vldisant
            ,reg_crapsld.vlblqant
            ,reg_crapsld.vlblqext
            ,reg_crapsld.vlblpant
            ,reg_crapsld.vlblpext
            ,reg_crapsld.vlblfant
            ,reg_crapsld.vlblfext
            ,reg_crapsld.vlchsant
            ,reg_crapsld.vlchsext
            ,reg_crapsld.vlindant
            ,reg_crapsld.vlindext
            ,reg_crapsld.smposano##1
            ,reg_crapsld.smposano##2
            ,reg_crapsld.smposano##3
            ,reg_crapsld.smposano##4
            ,reg_crapsld.smposano##5
            ,reg_crapsld.smposano##6
            ,reg_crapsld.smposano##7
            ,reg_crapsld.smposano##8
            ,reg_crapsld.smposano##9
            ,reg_crapsld.smposano##10
            ,reg_crapsld.smposano##11
            ,reg_crapsld.smposano##12
            ,reg_crapsld.smposant##1
            ,reg_crapsld.smposant##2
            ,reg_crapsld.smposant##3
            ,reg_crapsld.smposant##4
            ,reg_crapsld.smposant##5
            ,reg_crapsld.smposant##6
            ,reg_crapsld.smposant##7
            ,reg_crapsld.smposant##8
            ,reg_crapsld.smposant##9
            ,reg_crapsld.smposant##10
            ,reg_crapsld.smposant##11
            ,reg_crapsld.smposant##12
            ,reg_crapsld.smnegano##1
            ,reg_crapsld.smnegano##2
            ,reg_crapsld.smnegano##3
            ,reg_crapsld.smnegano##4
            ,reg_crapsld.smnegano##5
            ,reg_crapsld.smnegano##6
            ,reg_crapsld.smnegano##7
            ,reg_crapsld.smnegano##8
            ,reg_crapsld.smnegano##9
            ,reg_crapsld.smnegano##10
            ,reg_crapsld.smnegano##11
            ,reg_crapsld.smnegano##12
            ,reg_crapsld.smnegant##1
            ,reg_crapsld.smnegant##2
            ,reg_crapsld.smnegant##3
            ,reg_crapsld.smnegant##4
            ,reg_crapsld.smnegant##5
            ,reg_crapsld.smnegant##6
            ,reg_crapsld.smnegant##7
            ,reg_crapsld.smnegant##8
            ,reg_crapsld.smnegant##9
            ,reg_crapsld.smnegant##10
            ,reg_crapsld.smnegant##11
            ,reg_crapsld.smnegant##12
            ,reg_crapsld.smblqano##1
            ,reg_crapsld.smblqano##2
            ,reg_crapsld.smblqano##3
            ,reg_crapsld.smblqano##4
            ,reg_crapsld.smblqano##5
            ,reg_crapsld.smblqano##6
            ,reg_crapsld.smblqano##7
            ,reg_crapsld.smblqano##8
            ,reg_crapsld.smblqano##9
            ,reg_crapsld.smblqano##10
            ,reg_crapsld.smblqano##11
            ,reg_crapsld.smblqano##12
            ,reg_crapsld.smblqant##1
            ,reg_crapsld.smblqant##2
            ,reg_crapsld.smblqant##3
            ,reg_crapsld.smblqant##4
            ,reg_crapsld.smblqant##5
            ,reg_crapsld.smblqant##6
            ,reg_crapsld.smblqant##7
            ,reg_crapsld.smblqant##8
            ,reg_crapsld.smblqant##9
            ,reg_crapsld.smblqant##10
            ,reg_crapsld.smblqant##11
            ,reg_crapsld.smblqant##12
            ,reg_crapsld.smespano##1
            ,reg_crapsld.smespano##2
            ,reg_crapsld.smespano##3
            ,reg_crapsld.smespano##4
            ,reg_crapsld.smespano##5
            ,reg_crapsld.smespano##6
            ,reg_crapsld.smespano##7
            ,reg_crapsld.smespano##8
            ,reg_crapsld.smespano##9
            ,reg_crapsld.smespano##10
            ,reg_crapsld.smespano##11
            ,reg_crapsld.smespano##12
            ,reg_crapsld.smespant##1
            ,reg_crapsld.smespant##2
            ,reg_crapsld.smespant##3
            ,reg_crapsld.smespant##4
            ,reg_crapsld.smespant##5
            ,reg_crapsld.smespant##6
            ,reg_crapsld.smespant##7
            ,reg_crapsld.smespant##8
            ,reg_crapsld.smespant##9
            ,reg_crapsld.smespant##10
            ,reg_crapsld.smespant##11
            ,reg_crapsld.smespant##12
            ,reg_crapsld.vlblqjud);
        
        EXCEPTION
          WHEN dup_val_on_index THEN
            dbms_output.put_line('SLD: ' || reg_crapsld.cdcooper || '|' ||
                                 reg_crapsld.nrdconta);
        END;
      
        IF aux_vlsddisp <> 0 THEN
        
          tt_conferencia(aux_conf_index).cdagenci := reg_crapass.cdagenci;
          tt_conferencia(aux_conf_index).nrdconta := reg_crapass.nrdconta;
          tt_conferencia(aux_conf_index).vlsddisp := reg_crapsld.vlsddisp;
          tt_conferencia(aux_conf_index).vlsdbloq := reg_crapsld.vlsdbloq;
          tt_conferencia(aux_conf_index).vlsdblpr := reg_crapsld.vlsdblpr;
          tt_conferencia(aux_conf_index).vlsdblfp := reg_crapsld.vlsdblfp;
          tt_conferencia(aux_conf_index).vlsdchsl := reg_crapsld.vlsdchsl;
          tt_conferencia(aux_conf_index).vliofmes := reg_crapsld.vliofmes;
          tt_conferencia(aux_conf_index).vlsldtra := aux_vlsddisp;
          tt_conferencia(aux_conf_index).vlsdposi := aux_vlsdposi;
          tt_conferencia(aux_conf_index).vlsdnega := aux_vlsdnega;
          tt_conferencia(aux_conf_index).nrctavia := reg_crapass.new_nrdconta;
        
          aux_conf_index := tt_conferencia.count;
        
        END IF;
      
      END LOOP;
    
    END;
  
    --Saldos Diarios
    BEGIN
    
      -- Apaga registro criado anteriormente na migracao cadastro
      DELETE FROM crapsda
       WHERE crapsda.cdcooper = reg_crapass.new_cdcooper
         AND crapsda.nrdconta = reg_crapass.new_nrdconta;
    
      FOR reg_crapsda IN cur_crapsda(reg_crapass.cdcooper, reg_crapass.nrdconta) LOOP
      
        BEGIN
          INSERT INTO crapsda
            (cdcooper
            ,nrdconta
            ,dtmvtolt
            ,vlsddisp
            ,vlsdchsl
            ,vlsdbloq
            ,vlsdblpr
            ,vlsdblfp
            ,vlsdindi
            ,vllimcre
            ,vlsdeved
            ,vldeschq
            ,vllimutl
            ,vladdutl
            ,vlsdrdca
            ,vlsdrdpp
            ,vllimdsc
            ,vlprepla
            ,vlprerpp
            ,vlcrdsal
            ,qtchqliq
            ,qtchqass
            ,dtdsdclq
            ,vltotpar
            ,vlopcdia
            ,vlavaliz
            ,vlavlatr
            ,qtdevolu
            ,vltotren
            ,vldestit
            ,vllimtit
            ,vlsdempr
            ,vlsdfina
            ,vlsrdc30
            ,vlsrdc60
            ,vlsrdcpr
            ,vlsrdcpo
            ,vlsdcota
            ,vlblqjud)
          VALUES
            (reg_crapass.new_cdcooper
            ,reg_crapass.new_nrdconta
            ,reg_crapsda.dtmvtolt
            ,reg_crapsda.vlsddisp
            ,reg_crapsda.vlsdchsl
            ,reg_crapsda.vlsdbloq
            ,reg_crapsda.vlsdblpr
            ,reg_crapsda.vlsdblfp
            ,reg_crapsda.vlsdindi
            ,reg_crapsda.vllimcre
            ,reg_crapsda.vlsdeved
            ,reg_crapsda.vldeschq
            ,reg_crapsda.vllimutl
            ,reg_crapsda.vladdutl
            ,reg_crapsda.vlsdrdca
            ,reg_crapsda.vlsdrdpp
            ,reg_crapsda.vllimdsc
            ,reg_crapsda.vlprepla
            ,reg_crapsda.vlprerpp
            ,reg_crapsda.vlcrdsal
            ,reg_crapsda.qtchqliq
            ,reg_crapsda.qtchqass
            ,reg_crapsda.dtdsdclq
            ,reg_crapsda.vltotpar
            ,reg_crapsda.vlopcdia
            ,reg_crapsda.vlavaliz
            ,reg_crapsda.vlavlatr
            ,reg_crapsda.qtdevolu
            ,reg_crapsda.vltotren
            ,reg_crapsda.vldestit
            ,reg_crapsda.vllimtit
            ,reg_crapsda.vlsdempr
            ,reg_crapsda.vlsdfina
            ,reg_crapsda.vlsrdc30
            ,reg_crapsda.vlsrdc60
            ,reg_crapsda.vlsrdcpr
            ,reg_crapsda.vlsrdcpo
            ,reg_crapsda.vlsdcota
            ,reg_crapsda.vlblqjud);
        
        EXCEPTION
          WHEN dup_val_on_index THEN
            dbms_output.put_line('SDA: ' || reg_crapsda.cdcooper || '|' ||
                                 reg_crapsda.dtmvtolt || '|' ||
                                 reg_crapsda.nrdconta);
        END;
      END LOOP;
    END;
  
  END LOOP;

  -- Inicializar o CLOB (XML)
  dbms_lob.createtemporary(aux_dados, TRUE);
  dbms_lob.open(aux_dados, dbms_lob.lob_readwrite);

  aux_conf_index := 0;
  prc_escreve_clob('PA,Conta/Dv,Disponivel,Bloqueado,Bloqueado Praca,Bloqueado Fora Praca,Chq.Sal,IOF,Saldo Transferido');
  
  WHILE aux_conf_index < tt_conferencia.count LOOP
  
    IF (aux_age_anterior <> tt_conferencia(aux_conf_index).cdagenci AND aux_age_anterior <> 0) THEN
       prc_escreve_totais_agencia;
    END IF;
  
    aux_age_anterior := tt_conferencia(aux_conf_index).cdagenci;
  
    aux_linha := chr(13) || chr(10);
    aux_linha := aux_linha || tt_conferencia(aux_conf_index).cdagenci || ',';
    aux_linha := aux_linha || tt_conferencia(aux_conf_index).nrdconta || ',';
    aux_linha := aux_linha || '"' || TRIM(to_char(tt_conferencia(aux_conf_index).vlsddisp, aux_vlformat)) || '",';
    aux_linha := aux_linha || '"' || TRIM(to_char(tt_conferencia(aux_conf_index).vlsdbloq, aux_vlformat)) || '",';
    aux_linha := aux_linha || '"' || TRIM(to_char(tt_conferencia(aux_conf_index).vlsdblpr, aux_vlformat)) || '",';
    aux_linha := aux_linha || '"' || TRIM(to_char(tt_conferencia(aux_conf_index).vlsdblfp, aux_vlformat)) || '",';
    aux_linha := aux_linha || '"' || TRIM(to_char(tt_conferencia(aux_conf_index).vlsdchsl, aux_vlformat)) || '",';
    aux_linha := aux_linha || '"' || TRIM(to_char(tt_conferencia(aux_conf_index).vliofmes, aux_vlformat)) || '",';
    aux_linha := aux_linha || '"' || TRIM(to_char(tt_conferencia(aux_conf_index).vlsldtra, aux_vlformat)) || '"';
    
    prc_escreve_clob(aux_linha);
    
    aux_tot_age_count := aux_tot_age_count+1;
    aux_tot_age_vlsddisp := aux_tot_age_vlsddisp + tt_conferencia(aux_conf_index).vlsddisp;   
    aux_tot_age_vlsdbloq := aux_tot_age_vlsdbloq + tt_conferencia(aux_conf_index).vlsdbloq;
    aux_tot_age_vlsdblpr := aux_tot_age_vlsdblpr + tt_conferencia(aux_conf_index).vlsdblpr;
    aux_tot_age_vlsdblfp := aux_tot_age_vlsdblfp + tt_conferencia(aux_conf_index).vlsdblfp;
    aux_tot_age_vlsdchsl := aux_tot_age_vlsdchsl + tt_conferencia(aux_conf_index).vlsdchsl;
    aux_tot_age_vliofmes := aux_tot_age_vliofmes + tt_conferencia(aux_conf_index).vliofmes;
    aux_tot_age_vlsldtra := aux_tot_age_vlsldtra + tt_conferencia(aux_conf_index).vlsldtra;
    
    aux_tot_age_count := aux_tot_count+1;
    aux_tot_vlsddisp := aux_tot_vlsddisp + tt_conferencia(aux_conf_index).vlsddisp;   
    aux_tot_vlsdbloq := aux_tot_vlsdbloq + tt_conferencia(aux_conf_index).vlsdbloq;
    aux_tot_vlsdblpr := aux_tot_vlsdblpr + tt_conferencia(aux_conf_index).vlsdblpr;
    aux_tot_vlsdblfp := aux_tot_vlsdblfp + tt_conferencia(aux_conf_index).vlsdblfp;
    aux_tot_vlsdchsl := aux_tot_vlsdchsl + tt_conferencia(aux_conf_index).vlsdchsl;
    aux_tot_vliofmes := aux_tot_vliofmes + tt_conferencia(aux_conf_index).vliofmes;
    aux_tot_vlsldtra := aux_tot_vlsldtra + tt_conferencia(aux_conf_index).vlsldtra;
    
    IF (tt_conferencia(aux_conf_index).vlsldtra > 0) THEN
       aux_tot_age_vlsdposi := aux_tot_age_vlsdposi + tt_conferencia(aux_conf_index).vlsldtra;
       aux_tot_vlsdposi := aux_tot_vlsdposi + tt_conferencia(aux_conf_index).vlsldtra;
    ELSE
       aux_tot_age_vlsdnega := aux_tot_age_vlsdnega + tt_conferencia(aux_conf_index).vlsldtra;
       aux_tot_vlsdnega := aux_tot_vlsdnega + tt_conferencia(aux_conf_index).vlsldtra;
    END IF;
     
    aux_conf_index := aux_conf_index + 1;
    
  END LOOP;
  prc_escreve_totais_agencia;
  prc_escreve_totais_geral;

  -- Criar o arquivo no diretorio especificado
  -- SCTASK0038225 (Yuri - Mouts)
  gene0002.pc_clob_para_arquivo(pr_clob     => aux_dados 
                               ,pr_caminho  => aux_caminho 
                               ,pr_arquivo  => 'transf_dep_avista_scrmil.csv' 
                               ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    RAISE exc_erro ;
  END IF;
  -- FIM SCTASK0038225
/*  dbms_xslprocessor.clob2file(aux_dados, aux_caminho, 'transf_dep_avista_scrmil.csv', 0);*/

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(aux_dados);
  dbms_lob.freetemporary(aux_dados);

EXCEPTION
  WHEN exc_erro THEN
    ROLLBACK;
    dbms_output.put_line('ERRO GENE0002: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('ERRO: ' || SQLERRM);
END prc_transf_dep_avista_scrmil;
/

