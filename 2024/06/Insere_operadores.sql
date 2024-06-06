declare
  
  CURSOR cr_cooper IS
    SELECT c.cdcooper
    FROM CECRED.crapcop c
    WHERE c.flgativo = 1;
  
  vr_cdcooper   CECRED.crapcop.CDCOOPER%TYPE;
  
  TYPE tp_rec IS RECORD (
    operador    VARCHAR2(20)
    , nmoperad  VARCHAR2(60)
  );
  
  vr_operad   tp_rec;
  
  TYPE TP_OPE IS VARRAY(50) OF tp_rec;
  vr_operads  TP_OPE;
  
  vr_progress_id NUMBER;
  vr_dscritic    VARCHAR2(2000);
  vr_cdcritic    PLS_INTEGER;
  vr_exception   EXCEPTION;
  
begin
  
  vr_operads := TP_OPE();
  
  vr_operad.operador := 'f0030753';
  vr_operad.nmoperad := 'Kelvin Souza Ott';
  vr_operads.EXTEND(1);
  vr_operads(1) := vr_operad;
  
  vr_operad.operador := 't0034054';
  vr_operad.nmoperad := 'Lucas Souza';
  vr_operads.EXTEND(1);
  vr_operads(2) := vr_operad;
  
  vr_operad.operador := 't0034367';
  vr_operad.nmoperad := 'Gedeilson Lopes';
  vr_operads.EXTEND(1);
  vr_operads(3) := vr_operad;
  
  vr_operad.operador := 't0034132';
  vr_operad.nmoperad := 'Sidney Samir';
  vr_operads.EXTEND(1);
  vr_operads(4) := vr_operad;
  
  vr_operad.operador := 't0033844';
  vr_operad.nmoperad := 'Renato Caldeira';
  vr_operads.EXTEND(1);
  vr_operads(5) := vr_operad;
  
  vr_operad.operador := 't0034289';
  vr_operad.nmoperad := 'Hismahil';
  vr_operads.EXTEND(1);
  vr_operads(6) := vr_operad;
  
  vr_operad.operador := 't0034265';
  vr_operad.nmoperad := 'Rafael Fernandes';
  vr_operads.EXTEND(1);
  vr_operads(7) := vr_operad;
  
  vr_operad.operador := 't0034752';
  vr_operad.nmoperad := 'Jose Carlos';
  vr_operads.EXTEND(1);
  vr_operads(8) := vr_operad;
  
  vr_operad.operador := 't0033847';
  vr_operad.nmoperad := 'Marcos Aurelio';
  vr_operads.EXTEND(1);
  vr_operads(9) := vr_operad;
  
  vr_operad.operador := 't0033718';
  vr_operad.nmoperad := 'George Nicolas Ferreira';
  vr_operads.EXTEND(1);
  vr_operads(10) := vr_operad;
  
  vr_operad.operador := 't0035167';
  vr_operad.nmoperad := 'Thamires Rolnik Martins';
  vr_operads.EXTEND(1);
  vr_operads(11) := vr_operad;
  
  vr_operad.operador := 'f0034232';
  vr_operad.nmoperad := 'Marlon';
  vr_operads.EXTEND(1);
  vr_operads(12) := vr_operad;
  
  vr_operad.operador := 'f0030539';
  vr_operad.nmoperad := 'Heloiza';
  vr_operads.EXTEND(1);
  vr_operads(13) := vr_operad;
  
  vr_operad.operador := 'f0031800';
  vr_operad.nmoperad := 'Wagner da Silva';
  vr_operads.EXTEND(1);
  vr_operads(14) := vr_operad;
  
  vr_operad.operador := 't0033707';
  vr_operad.nmoperad := 'Geovani Aparecido';
  vr_operads.EXTEND(1);
  vr_operads(15) := vr_operad;
  
  vr_operad.operador := 't0033818';
  vr_operad.nmoperad := 'Daniel Teixeira';
  vr_operads.EXTEND(1);
  vr_operads(16) := vr_operad;
  
  vr_operad.operador := 'f0034120';
  vr_operad.nmoperad := 'Higor Renato de Araujo';
  vr_operads.EXTEND(1);
  vr_operads(17) := vr_operad;
  
  vr_operad.operador := 'f0033039';
  vr_operad.nmoperad := 'beatriz.cristina';
  vr_operads.EXTEND(1);
  vr_operads(18) := vr_operad;
  
  vr_operad.operador := 'T0035308';
  vr_operad.nmoperad := 'rodrigo.santos';
  vr_operads.EXTEND(1);
  vr_operads(19) := vr_operad;
  
  vr_operad.operador := 'f0033962';
  vr_operad.nmoperad := 'caroline.fsalvador';
  vr_operads.EXTEND(1);
  vr_operads(20) := vr_operad;
  
  vr_operad.operador := 'f0034153';
  vr_operad.nmoperad := 'daniel.agnolo';
  vr_operads.EXTEND(1);
  vr_operads(21) := vr_operad;
  
  vr_operad.operador := 't0034473';
  vr_operad.nmoperad := 'Alexandre Santos';
  vr_operads.EXTEND(1);
  vr_operads(22) := vr_operad;
  
  vr_operad.operador := 'f0034283';
  vr_operad.nmoperad := 'Beatriz Cristina';
  vr_operads.EXTEND(1);
  vr_operads(23) := vr_operad;
  
  vr_operad.operador := 'f0034528';
  vr_operad.nmoperad := 'Renato Caldeira';
  vr_operads.EXTEND(1);
  vr_operads(24) := vr_operad;
  
  vr_operad.operador := 'T0035090';
  vr_operad.nmoperad := 'Dennis Duarte';
  vr_operads.EXTEND(1);
  vr_operads(25) := vr_operad;
  
  vr_operad.operador := 'T0035233';
  vr_operad.nmoperad := 'Wilmondes Alvez';
  vr_operads.EXTEND(1);
  vr_operads(26) := vr_operad;
  
  vr_operad.operador := 'f0033529';
  vr_operad.nmoperad := 'f0033529';
  vr_operads.EXTEND(1);
  vr_operads(27) := vr_operad;
  
  vr_operad.operador := 't0034456';
  vr_operad.nmoperad := 't0034456';
  vr_operads.EXTEND(1);
  vr_operads(28) := vr_operad;
  
  vr_operad.operador := 't0033358';
  vr_operad.nmoperad := 'Luis Augusto C. Bertolini';
  vr_operads.EXTEND(1);
  vr_operads(29) := vr_operad;
  
  vr_operad.operador := 't0035811';
  vr_operad.nmoperad := 'Adriana Donizete Martin';
  vr_operads.EXTEND(1);
  vr_operads(30) := vr_operad;
  
  vr_operad.operador := 'f0034746';
  vr_operad.nmoperad := 'Jurliana Tonn';
  vr_operads.EXTEND(1);
  vr_operads(31) := vr_operad;
  
  vr_operad.operador := 'f0034443';
  vr_operad.nmoperad := 'Leandro Klug';
  vr_operads.EXTEND(1);
  vr_operads(32) := vr_operad;
  
  vr_operad.operador := 'f0034380';
  vr_operad.nmoperad := 'Operador f0034380';
  vr_operads.EXTEND(1);
  vr_operads(33) := vr_operad;
  
  vr_operad.operador := 'F0033398';
  vr_operad.nmoperad := 'Operador F0033398';
  vr_operads.EXTEND(1);
  vr_operads(34) := vr_operad;
  
  vr_operad.operador := 't0034169';
  vr_operad.nmoperad := 'Claudio Henrique';
  vr_operads.EXTEND(1);
  vr_operads(35) := vr_operad;
  
  vr_operad.operador := 't0035802';
  vr_operad.nmoperad := 'Francielly Cristine Silva Dos Santos';
  vr_operads.EXTEND(1);
  vr_operads(36) := vr_operad;
  
  vr_operad.operador := 'f0033500';
  vr_operad.nmoperad := 'Vanessa Salvador';
  vr_operads.EXTEND(1);
  vr_operads(37) := vr_operad;
  
  vr_operad.operador := 'f0034482';
  vr_operad.nmoperad := 'vinicio schmidt ';
  vr_operads.EXTEND(1);
  vr_operads(38) := vr_operad;
  
  vr_operad.operador := 't0034584';
  vr_operad.nmoperad := 'DENILSON MIRANDA';
  vr_operads.EXTEND(1);
  vr_operads(39) := vr_operad;
  
  vr_progress_id := 2001000;
  
  FOR i IN vr_operads.FIRST..vr_operads.LAST LOOP
    
    DBMS_OUTPUT.PUT_LINE( vr_operads(i).operador || ' - ' || vr_operads(i).nmoperad );
    
    IF cr_cooper%ISOPEN THEN
      CLOSE cr_cooper;
    END IF;
    
    OPEN cr_cooper;
    LOOP
      FETCH cr_cooper INTO vr_cdcooper;
      EXIT WHEN cr_cooper%NOTFOUND;
        
      vr_progress_id := vr_progress_id + 1;
        
      BEGIN
          
        INSERT INTO crapope (CDOPERAD
          , CDDSENHA, DTALTSNH, NRDEDIAS
          , NMOPERAD, CDSITOPE, NVOPERAD, TPOPERAD, VLPAGCHQ
          , CDCOOPER, CDAGENCI, FLGDOPGD, FLGACRES, DSDLOGIN, FLGDONET, VLAPVCRE, CDCOMITE, VLESTOR1, DSIMPRES, VLESTOR2, CDPACTRA, FLGPERAC
          , VLLIMTED, VLAPVCAP, CDDEPART, INSAQESP, DSDEMAIL, INUTLCRM, INSAQDES, PROGRESS_RECID)
        VALUES (vr_operads(i).operador
          , vr_operads(i).operador, to_date(SYSDATE, 'dd-mm-yyyy'), 30
          , vr_operads(i).nmoperad, 1, 2, 1, 0.00
          , vr_cdcooper, 1, 0, 0, ' ', 1, 0.00, 0, 0.00, ' ', 0.00, 1, 0
          , 0.00, 99999.00, 14, 0, ' ', 2, 1, vr_progress_id);
          
        DBMS_OUTPUT.PUT_LINE('   - Cooper: ' || vr_cdcooper);
          
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            
          IF INSTR(SQLERRM, 'CRAPOPE##CRAPOPE1', 1) > 0 THEN
              
            DBMS_OUTPUT.PUT_LINE( ' **** Operador JÁ cadastrado (CRAPOPE##CRAPOPE1): ' || vr_operads(i).operador || ' - ' || vr_operads(i).nmoperad || ' ( Cooper: ' || vr_cdcooper || ')' );
            NULL;
              
          ELSE 
            
            vr_dscritic := 'Erro ao inserir operador (DUP_VAL_ON_INDEX) ' || vr_operads(i).operador || ' - ' || SQLERRM;
            CLOSE cr_cooper;
              
            RAISE vr_exception;
            
          END IF;
            
        WHEN OTHERS THEN
            
          vr_dscritic := 'Erro ao inserir operador (OTHERS) ' || vr_operads(i).operador || ' - ' || SQLERRM;
          CLOSE cr_cooper;
            
          RAISE vr_exception;
            
      END;
        
    END LOOP;
      
    CLOSE cr_cooper;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    raise_application_error(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    
    raise_application_error(-20000, SQLERRM);

END;
