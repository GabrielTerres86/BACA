FOR rw_crapcop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP 

  insert into tbgen_sms_param (CDCOOPER, FLGENVIA_SMS, FLGCOBRA_TARIFA, HRENVIO_SMS, CDOPERAD, DTULTIMA_ATU, CDPRODUTO, CDTARIFA_PF, CDTARIFA_PJ)
  values (rw_crapcop.cdcooper, 1, 0, 0, '1', null, 31, null, null);

END LOOP;

COMMIT;
