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
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
