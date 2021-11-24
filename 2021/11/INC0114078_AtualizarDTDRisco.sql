DECLARE

  CURSOR cr_dtdrisco IS
    SELECT o12.dtdrisco, ris.progress_recid
      FROM tbrisco_central_ocr o12
         , tbrisco_central_ocr o16
         , tbrisco_central_ocr o18
         , crapris ris
     WHERE o12.cdcooper = o16.cdcooper
       AND o12.nrdconta = o16.nrdconta
       AND o12.nrctremp = o16.nrctremp
       AND o12.cdmodali = o16.cdmodali
       AND o12.inddocto = o16.inddocto
       AND o12.cdorigem = o16.cdorigem
       AND o12.cdcooper = o18.cdcooper
       AND o12.nrdconta = o18.nrdconta
       AND o12.nrctremp = o18.nrctremp
       AND o12.cdmodali = o18.cdmodali
       AND o12.inddocto = o18.inddocto
       AND o12.cdorigem = o18.cdorigem
       AND ris.nrdconta = o18.nrdconta
       AND ris.nrctremp = o18.nrctremp
       AND ris.cdmodali = o18.cdmodali
       AND ris.inddocto = o18.inddocto
       AND ris.cdorigem = o18.cdorigem
       AND ris.innivris = o12.inrisco_final
       --
       AND o12.dtdrisco <> o16.dtdrisco
       AND o12.dtdrisco <> o18.dtdrisco
       AND o12.dtrefere = TO_DATE('12/11/2021', 'dd/mm/YYYY')
       AND o16.dtrefere = TO_DATE('16/11/2021', 'dd/mm/YYYY')
       AND o18.dtrefere = TO_DATE('18/11/2021', 'dd/mm/YYYY')
       AND ris.dtrefere = TO_DATE('24/11/2021', 'dd/mm/YYYY') -- Data da Central de Risco se rodar dia 25/11
       --
       AND ris.dtdrisco = TO_DATE('18/11/2021', 'dd/mm/YYYY')
       AND o16.dtdrisco = TO_DATE('16/11/2021', 'dd/mm/YYYY')
       AND o18.dtdrisco = TO_DATE('18/11/2021', 'dd/mm/YYYY');

  idx    NUMBER;

BEGIN
  idx := 0;
  FOR linha IN cr_dtdrisco LOOP
    UPDATE crapris r SET r.dtdrisco = linha.dtdrisco WHERE r.progress_recid = linha.progress_recid;
    idx := idx + 1;
    IF idx > 2000 THEN
      idx := 0;
      COMMIT;
    END IF;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
