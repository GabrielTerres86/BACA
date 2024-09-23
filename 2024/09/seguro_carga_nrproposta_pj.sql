DECLARE
 CURSOR cr_icatu_pj(pr_cdcooper IN CECRED.crapcop.cdcooper%TYPE) IS
   SELECT p.dsvlrprm
    FROM CECRED.crapprm p
   WHERE p.nmsistem = 'CRED'
     AND p.cdacesso = 'PROPOSTA_API_ICATU_JURID'
     AND p.cdcooper = pr_cdcooper;

 CURSOR cr_icatu_qntd(pr_cdcooper IN CECRED.crapcop.cdcooper%TYPE) IS
   SELECT p.dsvlrprm
    FROM CECRED.crapprm p
   WHERE p.nmsistem = 'CRED'
     AND p.cdacesso = 'PROPOSTA_API_ICATU_QNTDJ'
     AND p.cdcooper = pr_cdcooper;

  vr_dsvlrprm CECRED.crapprm.dsvlrprm%TYPE;
BEGIN   
   FOR rw_cdcooper IN (SELECT c.cdcooper
                         FROM CECRED.crapcop c
                        WHERE c.flgativo = 1
                          AND c.cdcooper != 3) LOOP
      OPEN cr_icatu_pj(pr_cdcooper => rw_cdcooper.cdcooper);
        FETCH cr_icatu_pj INTO vr_dsvlrprm;
        IF cr_icatu_pj%NOTFOUND THEN
          INSERT INTO CECRED.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
            VALUES ('CRED', rw_cdcooper.cdcooper, 'PROPOSTA_API_ICATU_JURID', 'Quantidade de número de proposta disponível até a próxima carga', 'N');
        END IF;
      CLOSE cr_icatu_pj;
      
      OPEN cr_icatu_qntd(pr_cdcooper => rw_cdcooper.cdcooper);
        FETCH cr_icatu_qntd INTO vr_dsvlrprm;
        IF cr_icatu_qntd%NOTFOUND THEN
          INSERT INTO CECRED.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
            VALUES ('CRED', rw_cdcooper.cdcooper, 'PROPOSTA_API_ICATU_QNTDJ', 'Quantidade de número de proposta disponível até a próxima carga', 0);
        END IF;
      CLOSE cr_icatu_qntd;
   END LOOP;
   COMMIT;
END;
/
