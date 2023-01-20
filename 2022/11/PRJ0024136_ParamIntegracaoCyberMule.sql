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

  vr_tab_param(1).nmpartar := 'Integra��o Arquivo Telefone Cyber Vs Mulesoft';
  vr_tab_param(1).tpdedado := 2;
  vr_tab_param(1).cdprodut := 12;
  vr_tab_param(1).cdbattar := 'FLINTTELCYBMULE';
  vr_tab_param(1).nmidenti := 'Integra��o Arquivo Telefone Cyber Vs Mulesoft Ativada';
  vr_tab_param(1).cdprogra := ' ';
  vr_tab_param(1).tpcadast := 2;
  vr_tab_param(1).cdcooper := 3;
  vr_tab_param(1).dsconteu := '0';

  vr_tab_param(2).nmpartar := 'Diret�rio Integra��o Cyber Vs Mulesoft';
  vr_tab_param(2).tpdedado := 2;
  vr_tab_param(2).cdprodut := 12;
  vr_tab_param(2).cdbattar := 'DIRINTCYBMULE';
  vr_tab_param(2).nmidenti := 'Diret�rio Integra��o Cyber Vs Mulesoft';
  vr_tab_param(2).cdprogra := ' ';
  vr_tab_param(2).tpcadast := 2;
  vr_tab_param(2).cdcooper := 3;
  vr_tab_param(2).dsconteu := '/usr/sistemas/recuperacao/cyber/recebe';

  vr_tab_param(3).nmpartar := 'Integra��o Arquivo Distrib Cyber Vs Mulesoft';
  vr_tab_param(3).tpdedado := 2;
  vr_tab_param(3).cdprodut := 12;
  vr_tab_param(3).cdbattar := 'FLINTDISCYBMULE';
  vr_tab_param(3).nmidenti := 'Integra��o Arquivo Distrib Cyber Vs Mulesoft Ativada';
  vr_tab_param(3).cdprogra := ' ';
  vr_tab_param(3).tpcadast := 2;
  vr_tab_param(3).cdcooper := 3;
  vr_tab_param(3).dsconteu := '0';
  
  vr_tab_param(4).nmpartar := 'Integra��o Arquivo Quit Cyber Vs Mulesoft';
  vr_tab_param(4).tpdedado := 2;
  vr_tab_param(4).cdprodut := 12;
  vr_tab_param(4).cdbattar := 'FLINTQITCYBMULE';
  vr_tab_param(4).nmidenti := 'Integra��o Arquivo Quit Cyber Vs Mulesoft Ativada';
  vr_tab_param(4).cdprogra := ' ';
  vr_tab_param(4).tpcadast := 2;
  vr_tab_param(4).cdcooper := 3;
  vr_tab_param(4).dsconteu := '0';
  
  vr_tab_param(5).nmpartar := 'Integra��o Arquivo Queb Cyber Vs Mulesoft';
  vr_tab_param(5).tpdedado := 2;
  vr_tab_param(5).cdprodut := 12;
  vr_tab_param(5).cdbattar := 'FLINTQBRCYBMULE';
  vr_tab_param(5).nmidenti := 'Integra��o Arquivo Queb Cyber Vs Mulesoft Ativada';
  vr_tab_param(5).cdprogra := ' ';
  vr_tab_param(5).tpcadast := 2;
  vr_tab_param(5).cdcooper := 3;
  vr_tab_param(5).dsconteu := '0';
  
  vr_tab_param(6).nmpartar := 'Integra��o arq Legado Cyber Vs Mulesoft';
  vr_tab_param(6).tpdedado := 2;
  vr_tab_param(6).cdprodut := 12;
  vr_tab_param(6).cdbattar := 'FLINTLEGCYBMULE';
  vr_tab_param(6).nmidenti := 'Integra��o Arquivo Legado Cyber Vs Mulesoft Ativada';
  vr_tab_param(6).cdprogra := ' ';
  vr_tab_param(6).tpcadast := 2;
  vr_tab_param(6).cdcooper := 3;
  vr_tab_param(6).dsconteu := '0';
  
  vr_tab_param(7).nmpartar := 'Qtade de posi��es da conta arq Legado';
  vr_tab_param(7).tpdedado := 2;
  vr_tab_param(7).cdprodut := 12;
  vr_tab_param(7).cdbattar := 'PC657_CONTA';
  vr_tab_param(7).nmidenti := 'Quantidade de posi��es da conta no arquivo LEGADO';
  vr_tab_param(7).cdprogra := ' ';
  vr_tab_param(7).tpcadast := 2;
  vr_tab_param(7).cdcooper := 3;
  vr_tab_param(7).dsconteu := 8;
  
  vr_tab_param(8).nmpartar := 'Quantidade de posi��es do ctr arq Legado';
  vr_tab_param(8).tpdedado := 2;
  vr_tab_param(8).cdprodut := 12;
  vr_tab_param(8).cdbattar := 'PC657_CONTRATO';
  vr_tab_param(8).nmidenti := 'Quantidade de posi��es do contrato no arquivo LEGADO';
  vr_tab_param(8).cdprogra := ' ';
  vr_tab_param(8).tpcadast := 2;
  vr_tab_param(8).cdcooper := 3;
  vr_tab_param(8).dsconteu := 8;
  
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
