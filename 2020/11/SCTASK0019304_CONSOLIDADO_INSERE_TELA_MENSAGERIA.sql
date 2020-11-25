BEGIN
BEGIN
  DECLARE 
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CARCRD';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  BEGIN
    -- Buscar RDR
    OPEN  cr_craprdr;
    FETCH cr_craprdr INTO vr_nrseqrdr;
    -- Se nao encontrar
    IF cr_craprdr%NOTFOUND THEN
      INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CARCRD', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
    END IF;
    -- Fechar o cursor
    CLOSE cr_craprdr;
    
    INSERT INTO crapaca (
           nmdeacao, 
           nmpackag, 
           nmproced, 
           lstparam, 
           nrseqrdr
    ) VALUES (
           'ARQCCB_MANTER_ROTINA', 
           'MONITORAMENTO_ARQCCB', 
           'pc_manter_rotina_web', 
           'pr_operacao, pr_dtini, pr_dtfin, pr_contacartao', 
           vr_nrseqrdr
    );
    COMMIT;
    
  EXCEPTION 
    WHEN OTHERS THEN
    dbms_output.put_line('Erro ao executar: MONITORAMENTO_ARQCCB --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;

BEGIN
  DECLARE
    CURSOR cr_crapcop IS
      SELECT cdcooper
        FROM crapcop c
       WHERE c.flgativo = 1;
    
    CURSOR cr_crapope IS
      SELECT o.cdoperad
        FROM crapope o
       WHERE LOWER(o.cdoperad) IN ('f0030519')
       GROUP BY o.cdoperad;
  BEGIN
      FOR coop IN cr_crapcop LOOP
          INSERT INTO craptel
            (NMDATELA
            ,NRMODULO
            ,CDOPPTEL
            ,TLDATELA
            ,TLRESTEL
            ,FLGTELDF
            ,FLGTELBL
            ,NMROTINA
            ,LSOPPTEL
            ,INACESSO
            ,CDCOOPER
            ,IDSISTEM
            ,IDEVENTO
            ,NRORDROT
            ,NRDNIVEL
            ,NMROTPAI
            ,IDAMBTEL)
          VALUES
            ('CARCRD'
            ,5
            ,'@,C'
            ,'Monitoramento dos arquivos CCB'
            ,'Monitoramento dos arquivos CCB - CRPS672'
            ,0
            ,1
            ,'ARQCCB'
            ,'ACESSO,CONSULTA'
            ,0
            ,coop.cdcooper
            ,1
            ,0
            ,1
            ,1
            ,' '
            ,2);  
            
            
            FOR ope IN cr_crapope LOOP
              
                INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                values ('CARCRD', '@', ope.cdoperad, 'ARQCCB', coop.cdcooper, 1, 1, 2); 
                               
                INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                values ('CARCRD', 'C', ope.cdoperad, 'ARQCCB', coop.cdcooper, 1, 1, 2);                    
            
            END LOOP;
      END LOOP;
      
      COMMIT;
  END;
END;  


END;