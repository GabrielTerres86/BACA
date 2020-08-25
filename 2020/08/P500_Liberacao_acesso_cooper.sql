INSERT INTO tbgen_convenio_upload
  (CDCOOPER,
   NRDCONTA,
   NRCONTPJ,
   DTADESAO,
   TPCONVENIO,
   FLGHOMOLOGADO,
   CDOPERHO,
   DTHOMOLOGADO,
   INSITUAC,
   DTSITUAC,
   CDOPERAD)
VALUES
  (1,
   85448,
   2,
   TO_DATE(SYSDATE, 'dd-mm-yyyy'),
   2,
   'S',
   '1',
   TO_DATE(SYSDATE, 'dd-mm-yyyy'),
   1,
   TO_DATE(SYSDATE, 'dd-mm-yyyy hh24:mi:ss'),
   '1');
   
 COMMIT;