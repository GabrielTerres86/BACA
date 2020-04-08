BEGIN
  DECLARE
    CURSOR cr_cop IS
      SELECT c.cdcooper
        FROM crapcop c
       WHERE c.flgativo = 1;
    rw_cop cr_cop%ROWTYPE;
    
    vr_nrsolici INTEGER := 10001;
  BEGIN
    --RDR
	insert into craprdr (NMPROGRA, DTSOLICI)
	values ('GRVM0002', SYSDATE);
	
    FOR rw_cop IN cr_cop LOOP
      INSERT INTO CRAPPRG
        (NMSISTEM,
         CDPROGRA,
         DSPROGRA##1,
         DSPROGRA##2,
         DSPROGRA##3,
         DSPROGRA##4,
         NRSOLICI,
         NRORDPRG,
         INCTRPRG,
         CDRELATO##1,
         CDRELATO##2,
         CDRELATO##3,
         CDRELATO##4,
         CDRELATO##5,
         INLIBPRG,
         CDCOOPER,
         QTMINMED)
      VALUES
        ('CRED',
         'GRVM0002',
         'Definições de contratos/imagens',
         ' ',
         ' ',
         ' ',
         50,
         vr_nrsolici,
         1,
         0,
         0,
         0,
         0,
         0,
         1,
         rw_cop.cdcooper,
         NULL);
         vr_nrsolici := vr_nrsolici + 1;
    END LOOP;

    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('VALIDA_INCLUSAO_CONTRATO', 'GRVM0002', 'pc_valida_inclusao_contrato', 'pr_cdcooper,pr_nrdconta,pr_nrctrpro,pr_tpctrpro,pr_idseqbem,pr_cddopcao,pr_tpinclus', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'GRVM0002'));

	COMMIT;
  END;
END;

