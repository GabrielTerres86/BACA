DECLARE
  CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM cecred.crapbat
     WHERE cdbattar = pr_cdbattar;

  vr_cdpartar cecred.crappat.cdpartar%TYPE;

  TYPE typ_reg_param IS RECORD(
    nmpartar cecred.crappat.nmpartar%TYPE,
    tpdedado cecred.crappat.tpdedado%TYPE,
    cdprodut cecred.crappat.cdprodut%TYPE,
    cdbattar cecred.crapbat.cdbattar%TYPE,
    nmidenti cecred.crapbat.nmidenti%TYPE,
    cdprogra cecred.crapbat.cdprogra%TYPE,
    tpcadast cecred.crapbat.tpcadast%TYPE,
    cdcooper cecred.crappco.cdcooper%TYPE,
    dsconteu cecred.crappco.dsconteu%TYPE);

  TYPE typ_tab_param IS TABLE OF typ_reg_param INDEX BY VARCHAR2(50);

  vr_tab_param typ_tab_param;
BEGIN
  vr_tab_param.delete;

  vr_tab_param(1).nmpartar := 'IFRS9 - Linha de cr�dito renegocia��o da recupera��o de cr�dito';
  vr_tab_param(1).tpdedado := 1;
  vr_tab_param(1).cdprodut := 0;
  vr_tab_param(1).cdbattar := 'CDLCREDRENEG';
  vr_tab_param(1).nmidenti := 'IFRS9 - Linha de cr�dito renegocia��o da recupera��o de cr�dito';
  vr_tab_param(1).cdprogra := ' ';
  vr_tab_param(1).tpcadast := 2;
  vr_tab_param(1).cdcooper := 3;
  vr_tab_param(1).dsconteu := '0';

  vr_tab_param(2).nmpartar := 'IFRS9 - Finalidade renegocia��o da recupera��o de cr�dito';
  vr_tab_param(2).tpdedado := 1;
  vr_tab_param(2).cdprodut := 0;
  vr_tab_param(2).cdbattar := 'CDFINALRENEG';
  vr_tab_param(2).nmidenti := 'IFRS9 - Finalidade renegocia��o da recupera��o de cr�dito';
  vr_tab_param(2).cdprogra := ' ';
  vr_tab_param(2).tpcadast := 2;
  vr_tab_param(2).cdcooper := 3;
  vr_tab_param(2).dsconteu := '0';

  vr_tab_param(3).nmpartar := 'IFRS9 - Tipo empr�stimo renegocia��o da recupera��o de cr�dito';
  vr_tab_param(3).tpdedado := 1;
  vr_tab_param(3).cdprodut := 0;
  vr_tab_param(3).cdbattar := 'TPEMPRTRENEG';
  vr_tab_param(3).nmidenti := 'IFRS9 - Tipo empr�stimo renegocia��o da recupera��o de cr�dito';
  vr_tab_param(3).cdprogra := ' ';
  vr_tab_param(3).tpcadast := 2;
  vr_tab_param(3).cdcooper := 3;
  vr_tab_param(3).dsconteu := '0';

  vr_tab_param(4).nmpartar := 'IFRS9 - Habilitar renegocia��o da recupera��o de cr�dito';
  vr_tab_param(4).tpdedado := 1;
  vr_tab_param(4).cdprodut := 0;
  vr_tab_param(4).cdbattar := 'INIFRS9RECUP';
  vr_tab_param(4).nmidenti := 'IFRS9 - Habilitar renegocia��o da recupera��o de cr�dito';
  vr_tab_param(4).cdprogra := ' ';
  vr_tab_param(4).tpcadast := 2;
  vr_tab_param(4).cdcooper := 3;
  vr_tab_param(4).dsconteu := '0';

  FOR idx IN vr_tab_param.first .. vr_tab_param.last LOOP
    FOR rw_crapbat IN cr_crapbat(pr_cdbattar => vr_tab_param(idx).cdbattar) LOOP
      DELETE 
        FROM cecred.crapbat
       WHERE cdcadast = rw_crapbat.cdcadast;
    
      DELETE 
        FROM cecred.crappat
       WHERE cdpartar = rw_crapbat.cdcadast;
    
      DELETE 
        FROM cecred.crappco
       WHERE cdpartar = rw_crapbat.cdcadast;
    END LOOP;
  
    SELECT nvl(MAX(cdpartar), 0) + 1 cdpartar
      INTO vr_cdpartar
      FROM cecred.crappat;
  
    INSERT INTO cecred.crappat
      (cdpartar
      ,nmpartar
      ,tpdedado
      ,cdprodut)
    VALUES
      (vr_cdpartar
      ,vr_tab_param(idx).nmpartar
      ,vr_tab_param(idx).tpdedado
      ,vr_tab_param(idx).cdprodut);
  
    INSERT INTO cecred.crapbat
      (cdbattar
      ,nmidenti
      ,cdprogra
      ,tpcadast
      ,cdcadast)
    VALUES
      (vr_tab_param(idx).cdbattar
      ,vr_tab_param(idx).nmidenti
      ,vr_tab_param(idx).cdprogra
      ,vr_tab_param(idx).tpcadast
      ,vr_cdpartar);
  
    INSERT INTO cecred.crappco
      (cdpartar
      ,cdcooper
      ,dsconteu)
    VALUES
      (vr_cdpartar
      ,vr_tab_param(idx).cdcooper
      ,vr_tab_param(idx).dsconteu);
  
    COMMIT;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;