DECLARE
  TYPE Cooperativas IS TABLE OF integer;
--  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);
  coop Cooperativas := Cooperativas(3);
  v_nrseqrdr number;
  pr_cdcooper INTEGER;
  
  v_nmdatela varchar2(40) := 'MOVCMP';
  v_cdprogra varchar2(40) := 'MOVCMP';
  v_nmdeacao varchar2(40) := 'CONSULTAMOVCMP';
  v_nmprogra varchar2(40) := 'TELA_MOVCMP';
  v_desc     varchar2(100):= 'Movimento dos documentos da compensação';
  v_nmpackag varchar2(40) := 'TELA_MOVCMP';
  v_nmproced varchar2(40) := 'pc_busca_mremessa';
  v_param varchar2(4000)  := 'pr_vcooper,pr_tpremessa,pr_cdagenci,pr_tparquivo,pr_dtinicial,pr_dtfinal,pr_nriniseq,pr_nrregist'; 
BEGIN

  -- remove qualquer "lixo" de BD que possa ter  
  
  DELETE FROM craptel WHERE nmdatela = v_nmdatela;
  DELETE FROM crapace WHERE nmdatela = v_nmdatela;
  DELETE FROM crapprg WHERE cdprogra = v_cdprogra;
  DELETE FROM crapaca WHERE nmdeacao = v_nmdeacao;
  DELETE FROM craprdr where nmprogra = v_nmprogra;

  
  FOR i IN coop.FIRST .. coop.LAST LOOP
    pr_cdcooper := coop(i);
    -- Insere a tela
    INSERT INTO craptel
      (nmdatela,
       nrmodulo,
       cdopptel,
       tldatela,
       tlrestel,
       flgteldf,
       flgtelbl,
       nmrotina,
       lsopptel,
       inacesso,
       cdcooper,
       idsistem,
       idevento,
       nrordrot,
       nrdnivel,
       nmrotpai,
       idambtel)
      SELECT v_nmdatela,
             3,
             --'A,C,E,I,H',
       'C',
             v_desc,
             v_desc,
             0,
             1, -- bloqueio da tela 
             ' ',
             'CONSULTA',
             1,
             pr_cdcooper, -- cooperativa
             1,
             0,
             0,
             0,
             '',
             2
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED   
/*  
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'LINCRE', 'A', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  */
    -- Permissões de consulta para os usuários pré-definidos pela CECRED
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT v_nmdatela, 'C', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  /*
    -- Permissões de consulta para os usuários pré-definidos pela CECRED                       
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'LINCRE', 'E', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  */
    -- Permissões de consulta para os usuários pré-definidos pela CECRED   
/*  
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'LINCRE', 'I', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  */
    -- Permissões de consulta para os usuários pré-definidos pela CECRED       
/*  
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'LINCRE', 'H', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  */
    -- Insere o registro de cadastro do programa
    INSERT INTO crapprg
      (nmsistem,
       cdprogra,
       dsprogra##1,
       dsprogra##2,
       dsprogra##3,
       dsprogra##4,
       nrsolici,
       nrordprg,
       inctrprg,
       cdrelato##1,
       cdrelato##2,
       cdrelato##3,
       cdrelato##4,
       cdrelato##5,
       inlibprg,
       cdcooper)
      SELECT 'CRED',
             v_cdprogra,
             v_desc,
             '.',
             '.',
             '.',
             50,
             (select max(crapprg.nrordprg) + 1
                from crapprg
               where crapprg.cdcooper = crapcop.cdcooper
                 and crapprg.nrsolici = 50),
             1,
             0,
             0,
             0,
             0,
             0,
             1,
             cdcooper
        FROM crapcop
       WHERE cdcooper IN (pr_cdcooper);
  
  END LOOP;

-- armazenar tela para interface web
insert into craprdr (NMPROGRA, DTSOLICI) values (v_nmprogra, sysdate) returning nrseqrdr into v_nrseqrdr;

-- INSERE AÇÃO DA TELA DO AYLLOS WEB
    INSERT INTO CRAPACA(NMDEACAO, 
                        NMPACKAG, 
                        NMPROCED, 
                        LSTPARAM, 
                        NRSEQRDR) 
                 VALUES(v_nmdeacao,
                        v_nmpackag,
                        v_nmproced,
                        v_param,
                        v_nrseqrdr);
                        

						insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('SUMLNCCHQ', 'cheq0001', 'pc_busca_sum_lanc_chq_web', 'pr_cdcooper,pr_nrdconta,pr_nrdocmto', (select nrseqrdr from craprdr where nmprogra = 'CHEQUE'));
commit;

END;     






