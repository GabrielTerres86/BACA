--CRIA��O DE DOM�NIO
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',1, 'IM�VEL');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',2, 'VE�CULO');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',3, 'M�QUINA E EQUIPAMENTO');
INSERT INTO tbgen_dominio_campo VALUES ('TPBENS_DACAO',4, 'OUTROS - BENS E DIREITOS');
--Categoria Da��o Bens - IM�VEL
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0101, 'Urbano Residencial');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0102, 'Urbano Comercial');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0103, 'Urbano Rural');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0104, 'Outros Im�veis');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0105, 'Planta Industrial');
--Categoria Da��o Bens - VE�CULO
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0201, 'Autom�vel');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0202, 'Caminhonete');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0203, 'Motocicleta');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0204, 'Caminh�o');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0205, 'Outros Terrestres');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0206, 'Embarca��es');
--Categoria Da��o Bens - M�QUINAS E EQUIPAMENTOS
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0301, 'Maquin�rio comercial/fabril');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0302, 'Agr�cola');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0303, 'Produto Agr�cola');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0304, 'Produto Fabril');
--Categoria Da��o Bens - OUTROS - BENS E DIREITOS
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0401, 'Diretos de Uso');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0402, 'Outros Bens e Direitos');
INSERT INTO tbgen_dominio_campo VALUES ('TPCATBEM',0403, 'Instrumentos Financeiros');
--
COMMIT;
--
--CRIA��O DE MENSAGEIRIA - GRAVAR_DACAO_BENS
DELETE FROM CRAPACA
 WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_PRESTACOES')
   AND NMDEACAO = 'GRAVAR_DACAO_BENS';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'GRAVAR_DACAO_BENS',
   'TELA_ATENDA_PRESTACOES',
   'pc_gravar_dacao_bens',
   'pr_nrdconta, pr_ncrtremp,
 pr_tpctrpro,
 pr_tpbens_dacao,
 pr_nrmatricula,
 pr_nrregistro_imovel,
 pr_cdnacional_serventia,
 pr_dsmarbem,
 pr_dsmodbem,
 pr_nranobem,
 pr_nrmodbem,
 pr_dschassi,
 pr_ufdplaca,
 pr_dsdplaca,
 pr_nrrenava,
 pr_uflicenc,
 pr_dsrelbem,
 pr_nrnotanf,
 pr_vlrdobem,
 pr_tpcatbem',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_PRESTACOES'));
COMMIT;
--
--PERMISS�ES DE ACESSO A OP��O R 'RECEBIMENTO DE BENS'
UPDATE CRAPTEL
   SET CDOPPTEL = CDOPPTEL || ',R', 
       LSOPPTEL = LSOPPTEL || ',RECEBIMENTO BENS'
 WHERE UPPER(NMDATELA) LIKE UPPER('%ATENDA%')
   AND UPPER(NMROTINA) LIKE UPPER('PRESTACOES')
   AND (CDOPPTEL NOT LIKE '%R%');
COMMIT;
--
--PERMISS�ES DE ACESSO PARA USU�RIOS AO CAMPO 'DA��O DE BENS'
DECLARE
  TYPE typ_tab_rotinas IS
    TABLE OF VARCHAR2(30)
      INDEX BY PLS_INTEGER;
  vr_tab_rotinas typ_tab_rotinas;
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1
       AND cdcooper <> 3
     ORDER BY cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cdoperad
      FROM crapope t
     WHERE cdcooper = pr_cdcooper
       AND upper(t.cdoperad) IN (upper('F0020271')--USU�RIOS DE TESTES E DEVEM SER SUBSTITUIDOS PELA LISTA QUE A  jOSI IR� PASSAR
                                ,upper('F0020206')
                                ,upper('F0020113')
                                ,upper('F0020001') 
                                ,upper('F0020048')
                                ,upper('F0020295')
                                );
  rw_crapope cr_crapope%ROWTYPE;
  sigla_tela  VARCHAR2(400);
  rotina_tela VARCHAR2(400);
  vr_contador INTEGER;
BEGIN
  -- Lista de rotinas que precisam ser criadas a Op��o T
  vr_tab_rotinas(1) := 'PRESTACOES';
 
  FOR rw_crapcop IN cr_crapcop LOOP
    
    dbms_output.put_line('COOP: ' || rw_crapcop.cdcooper );
    
    -- APAGAR OS REGISTROS DE QUEM JA TEM ACESSO A OP��O ALTERAR RATING DOS PRODUTOS
    sigla_tela := 'ATENDA';
    FOR vr_contador IN 1..vr_tab_rotinas.count LOOP
      BEGIN
        DELETE FROM crapace t
         WHERE t.cdcooper = rw_crapcop.cdcooper
           AND UPPER(t.nmdatela) = UPPER(sigla_tela)
           AND UPPER(T.NMROTINA) = UPPER(vr_tab_rotinas(vr_contador))
           AND UPPER(CDDOPCAO)   = UPPER('R');
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Exclus�o ACESSO n�o realizada!'  ||
                                ' Coop:' || rw_crapcop.cdcooper 
                             || ' OP��O R'
                             || ' TELA: ' || sigla_tela
                             || ' Rotina: ' || vr_tab_rotinas(vr_contador)
                                  );
      END;
    END LOOP;
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper) LOOP
      dbms_output.put_line('  OPERAD: ' || rw_crapope.cdoperad);
      sigla_tela := 'ATENDA';
      FOR vr_contador IN 1..vr_tab_rotinas.count LOOP
        dbms_output.put_line('    Rotina: ' || vr_tab_rotinas(vr_contador));
        BEGIN
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
            (sigla_tela
            ,'R'
            ,rw_crapope.cdoperad
            ,vr_tab_rotinas(vr_contador)
            ,rw_crapcop.cdcooper
            ,1
            ,0
            ,2);
          dbms_output.put_line('Inser��o em crapace  realizada com sucesso!  ' ||
                               ' TELA: ' || sigla_tela || 
                               ' Rotina: ' || vr_tab_rotinas(vr_contador)
                            || ' Opcao R' 
                            || ' Coop:'    || rw_crapcop.cdcooper 
                            || ' Operador ' || rw_crapope.cdoperad);
        EXCEPTION
          WHEN dup_val_on_index THEN
            dbms_output.put_line('Inser��o em crapace n�o realizada.  J� EXISTE REGISTRO PARA  OPERADOR ' ||
                                 rw_crapope.cdoperad ||
                                  ' Coop:' || rw_crapcop.cdcooper || ' OP��O R'
                               || ' TELA: ' || sigla_tela || ' Rotina: ' || vr_tab_rotinas(vr_contador)
                                  );
        END;
      END LOOP; -- Fim do loop das rotinas Atenda
     
    END LOOP;
  END LOOP;
  COMMIT;
END;

