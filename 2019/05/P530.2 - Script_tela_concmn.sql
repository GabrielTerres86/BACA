DECLARE
  TYPE cooperativas IS TABLE OF INTEGER;
  coop        cooperativas := cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);
  v_nrseqrdr  NUMBER;
  pr_cdcooper INTEGER;

  CURSOR cr_operadores IS
    SELECT 'CONCMN' nmdatela
          ,'C' cddopcao
          ,ope.cdoperad
          ,' ' nmrotina
          ,cop.cdcooper
          ,1 nrmodulo
          ,0 idevento
          ,2 idambace
      FROM crapcop cop, crapope ope
     WHERE cop.cdcooper = pr_cdcooper
       AND ope.cdsitope = 1
       AND cop.cdcooper = ope.cdcooper
       AND ope.cddepart IN (1, 13);
  creg cr_operadores%ROWTYPE;
BEGIN

  -- remove qualquer "lixo" de BD que possa ter

  dbms_output.put_line('Ponto 1: ' || to_char(SYSDATE, 'hh24:mi:ss'));
  DELETE FROM craptel WHERE nmdatela = 'CONCMN';
  DELETE FROM crapace WHERE nmdatela = 'CONCMN';
  DELETE FROM crapprg WHERE cdprogra = 'CONCMN';
  DELETE FROM crapaca WHERE nmdeacao = 'CONSULTACONCMN';
  DELETE FROM craprdr WHERE nmprogra = 'TELA_CONCMN';

  dbms_output.put_line('Ponto 2: ' || to_char(SYSDATE, 'hh24:mi:ss'));

  FOR i IN coop.first .. coop.last LOOP
    pr_cdcooper := coop(i);
    -- Insere a tela
    INSERT INTO craptel
      (nmdatela
      ,nrmodulo
      ,cdopptel
      ,tldatela
      ,tlrestel
      ,flgteldf
      ,flgtelbl
      ,nmrotina
      ,lsopptel
      ,inacesso
      ,cdcooper
      ,idsistem
      ,idevento
      ,nrordrot
      ,nrdnivel
      ,nmrotpai
      ,idambtel)
      SELECT 'CONCMN'
            ,1
            ,'C'
            ,'Consulta de Contas Monitoradas'
            ,'Consulta de Contas Monitoradas'
            ,0
            ,1
            , -- bloqueio da tela
             ' '
            ,'CONSULTA'
            ,1
            ,pr_cdcooper
            , -- cooperativa
             1
            ,0
            ,0
            ,0
            ,''
            ,2
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
  
    dbms_output.put_line('Ponto 3: ' || to_char(SYSDATE, 'hh24:mi:ss'));
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED
    OPEN cr_operadores;
    FETCH cr_operadores
      INTO creg;
    WHILE (cr_operadores%FOUND) LOOP
      --       dbms_output.put_line('Ponto 3.1: '||to_char(sysdate,'hh24:mi:ss'));
      INSERT INTO crapace
        (nmdatela
        ,cddopcao
        ,cdoperad
        ,nmrotina
        ,cdcooper
        ,nrmodulo
        ,idevento
        ,idambace)
      VALUES
        (creg.nmdatela
        ,creg.cddopcao
        ,creg.cdoperad
        ,creg.nmrotina
        ,creg.cdcooper
        ,creg.nrmodulo
        ,creg.idevento
        ,creg.idambace);
    
      FETCH cr_operadores
        INTO creg;
    END LOOP;
    CLOSE cr_operadores;
  
    dbms_output.put_line('Ponto 4: ' || to_char(SYSDATE, 'hh24:mi:ss'));
  
    -- Insere o registro de cadastro do programa
    INSERT INTO crapprg
      (nmsistem
      ,cdprogra
      ,dsprogra##1
      ,dsprogra##2
      ,dsprogra##3
      ,dsprogra##4
      ,nrsolici
      ,nrordprg
      ,inctrprg
      ,cdrelato##1
      ,cdrelato##2
      ,cdrelato##3
      ,cdrelato##4
      ,cdrelato##5
      ,inlibprg
      ,cdcooper)
      SELECT 'CRED'
            ,'CONCMN'
            ,'Consulta de Contas Monitoradas'
            ,'.'
            ,'.'
            ,'.'
            ,50
            ,(SELECT MAX(crapprg.nrordprg) + 1
               FROM crapprg
              WHERE crapprg.cdcooper = crapcop.cdcooper
                AND crapprg.nrsolici = 50)
            ,1
            ,0
            ,0
            ,0
            ,0
            ,0
            ,1
            ,cdcooper
        FROM crapcop
       WHERE cdcooper IN (pr_cdcooper);
  
    dbms_output.put_line('Ponto 5: ' || to_char(SYSDATE, 'hh24:mi:ss'));
  
  END LOOP;

  -- armazenar tela para interface web
  INSERT INTO craprdr
    (nmprogra
    ,dtsolici)
  VALUES
    ('TELA_CONCMN'
    ,SYSDATE)
  RETURNING nrseqrdr INTO v_nrseqrdr;

  dbms_output.put_line('Ponto 6: ' || to_char(SYSDATE, 'hh24:mi:ss'));

  -- INSERE AÇÃO DA TELA DO AYLLOS WEB
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('CONSULTACONCMN'
    ,'BLQJ0002'
    ,'PC_CONSULTAR_CONCMN'
    ,'pr_nrdconta,pr_nrcpfcgc,pr_vcooper,pr_nriniseq,pr_nrregist'
    ,v_nrseqrdr);

  dbms_output.put_line('Ponto 7: ' || to_char(SYSDATE, 'hh24:mi:ss'));

  COMMIT;
END;
