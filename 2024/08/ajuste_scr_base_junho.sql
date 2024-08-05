DECLARE
  CURSOR cr_principal IS
    SELECT a.nrcpfcgc nrcpfcgc_destino
          ,o.nrcpfcgc nrcpfcgc_origem
          ,o.dtrefere
          ,o.qtopesfn
          ,o.qtifssfn
          ,o.qtsbjsfn
          ,o.vlsbjsfn
          ,o.percdocp
          ,o.percvolp
          ,o.inpessoa
          ,o.idopf_header
          ,o.dtinirlc
          ,o.qtopemnf
          ,o.vlopemnf
          ,o.vlcooacc
          ,o.vlrisinv
          ,o.vlcoorcc
      FROM cecred.crapopf o
          ,cecred.crapass a
     WHERE o.dtrefere = to_date('30/06/2024', 'DD/MM/RRRR')
       AND a.nrcpfcnpj_base = SUBSTR(LPAD(o.nrcpfcgc, 14, '0'),1,8)
       AND a.inpessoa = o.inpessoa
       AND o.inpessoa = 2
       AND o.nrcpfcgc <> a.nrcpfcgc
       AND NOT EXISTS (SELECT 1 
                         FROM cecred.crapopf x 
                        WHERE x.nrcpfcgc = a.nrcpfcgc 
                          AND x.dtrefere = o.dtrefere);
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_crapvop(pr_nrcpfcgc IN cecred.crapvop.nrcpfcgc%TYPE
                   ,pr_dtrefere IN cecred.crapvop.dtrefere%TYPE) IS
    SELECT v.nrcpfcgc
          ,v.dtrefere
          ,v.cdvencto
          ,v.vlvencto
          ,v.cdmodali
          ,v.flgmoest
      FROM cecred.crapvop v
     WHERE v.nrcpfcgc = pr_nrcpfcgc
       AND v.dtrefere = pr_dtrefere;
  rw_crapvop cr_crapvop%ROWTYPE;
BEGIN
  
  UPDATE CRAPPRM
   SET DSVLRPRM = '999'
 WHERE NMSISTEM = 'CRED'
   AND CDCOOPER = 0
   AND CDACESSO = 'QTDIAEXPURGOCARGA_RISCO';
  
  COMMIT;
  
  FOR rw_principal IN cr_principal LOOP
    BEGIN
      INSERT INTO cecred.crapopf(nrcpfcgc, dtrefere, qtopesfn, qtifssfn, qtsbjsfn, vlsbjsfn, percdocp,
                                 percvolp, inpessoa, idopf_header, dtinirlc, qtopemnf, vlopemnf, vlcooacc,
                                 vlrisinv, vlcoorcc)
      VALUES(rw_principal.nrcpfcgc_destino, rw_principal.dtrefere, rw_principal.qtopesfn, rw_principal.qtifssfn, rw_principal.qtsbjsfn, rw_principal.vlsbjsfn, rw_principal.percdocp,
             rw_principal.percvolp, rw_principal.inpessoa, rw_principal.idopf_header, rw_principal.dtinirlc, rw_principal.qtopemnf, rw_principal.vlopemnf, rw_principal.vlcooacc,
             rw_principal.vlrisinv, rw_principal.vlcoorcc);
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao inserir crapopf - nrcpfcgc: ' || rw_principal.nrcpfcgc_destino);
    END;
    
    FOR rw_crapvop IN cr_crapvop(pr_nrcpfcgc => rw_principal.nrcpfcgc_origem
                                ,pr_dtrefere => rw_principal.dtrefere) LOOP
      BEGIN
        INSERT INTO cecred.crapvop(nrcpfcgc, dtrefere, cdvencto, vlvencto, cdmodali, flgmoest)
        VALUES (rw_principal.nrcpfcgc_destino, rw_crapvop.dtrefere, rw_crapvop.cdvencto, rw_crapvop.vlvencto, rw_crapvop.cdmodali, rw_crapvop.flgmoest);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao inserir crapvop - nrcpfcgc: ' || rw_principal.nrcpfcgc_destino);
      END;
      
      COMMIT;
      
    END LOOP;
    
    COMMIT;
  END LOOP;

  insert into cecred.crapopf (NRCPFCGC, DTREFERE, QTOPESFN, QTIFSSFN, QTSBJSFN, VLSBJSFN, PERCDOCP, PERCVOLP, INPESSOA, IDOPF_HEADER, DTINIRLC, QTOPEMNF, VLOPEMNF, VLCOOACC, VLRISINV, VLCOORCC)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 53, 11, 0, 0.00, 0.00, 0.00, 2, 3804, to_date('18/01/1990', 'DD/MM/RRRR'), 0, 0.00, 0.00, 0.00, 0.00);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 110, 535228.06, '0213', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 165, 360980.70, '0213', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 110, 136963.30, '0215', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 120, 132170.35, '0215', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 130, 130015.83, '0215', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 140, 878054.50, '0215', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 150, 705637.23, '0215', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 160, 1133255.99, '0215', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 165, 1033739.32, '0215', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 170, 857175.14, '0215', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 110, 1228187.62, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 120, 852052.65, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 130, 664704.55, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 140, 2929515.37, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 150, 5945246.47, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 160, 9805640.63, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 165, 5882492.42, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 170, 879108.55, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 175, 86897.40, '0216', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 110, 323997.51, '0299', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 120, 71428.56, '0299', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 130, 47619.04, '0299', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 140, 214285.68, '0299', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 150, 428571.36, '0299', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 160, 857142.72, '0299', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 165, 619047.84, '0299', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 170, 95238.24, '0299', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 110, 13247.57, '0402', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 120, 13059.66, '0402', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 130, 12874.44, '0402', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 140, 34792.29, '0402', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 150, 56534.70, '0402', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 160, 93767.79, '0402', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 165, 59741.20, '0402', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 170, 3554.79, '0402', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 110, 553982.43, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 120, 316704.48, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 130, 242187.52, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 140, 911897.23, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 150, 1217265.53, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 160, 2324602.48, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 165, 1923058.13, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 170, 1365575.26, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 175, 101044.21, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 180, 20767.45, '0499', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 140, 297526.18, '1502', 1);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 20, 49993.83, '1902', 0);

  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/06/2024', 'DD/MM/RRRR'), 20, 486290.78, '1904', 0);

  commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
