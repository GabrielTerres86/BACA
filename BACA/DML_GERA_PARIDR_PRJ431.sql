
/******************************************************************************************************** 
  Baca para criar vinculações (PARIDR)
  -----------------
   Autor: Augusto (Supero)                                 Data: 16/07/2018
  -----------------
*********************************************************************************************************/

DECLARE

    -- A tela deverá ser criara para as coops ativas
    CURSOR cr_crapcop IS
        SELECT cdcooper FROM crapcop p WHERE p.flgativo = 1;

    CURSOR cr_vinculacoes(pr_cdcooper               tbrecip_vinculacao_parame_coop.cdcooper%TYPE
                         ,pr_inpessoa               tbrecip_vinculacao_parame_coop.inpessoa%TYPE
                         ,pr_idvinculacao_reciproci tbrecip_vinculacao_parame_coop.idvinculacao_reciproci%TYPE) IS
        SELECT tvpc.idvinculacao_reciproci
          FROM tbrecip_vinculacao_parame_coop tvpc
         WHERE tvpc.cdcooper = pr_cdcooper
           AND tvpc.inpessoa = pr_inpessoa
           AND tvpc.idvinculacao_reciproci = pr_idvinculacao_reciproci;
    rw_vinculacoes cr_vinculacoes%ROWTYPE;

    vr_perdesconto VARCHAR2(40);

BEGIN
    --
    dbms_output.put_line('INICIO');
    --
    FOR rw_crapcop IN cr_crapcop LOOP
        FOR idx IN 1 .. 4 LOOP
        
            CASE idx
                WHEN 1 THEN
                    vr_perdesconto := 40;
                WHEN 2 THEN
                    vr_perdesconto := 30;
                WHEN 3 THEN
                    vr_perdesconto := 20;
                WHEN 4 THEN
                    vr_perdesconto := 10;
                ELSE
                    vr_perdesconto := 0;
            END CASE;
        
            OPEN cr_vinculacoes(rw_crapcop.cdcooper, 1, idx);
            FETCH cr_vinculacoes
                INTO rw_vinculacoes;
        
            IF cr_vinculacoes%NOTFOUND THEN
                --
                dbms_output.put_line('INSERINDO VINCULACOES PARA PF ' || idx);
                --
                INSERT INTO tbrecip_vinculacao_parame_coop
                    (cdcooper
                    ,idvinculacao_reciproci
                    ,cdproduto
                    ,inpessoa
                    ,vlpercentual_peso
                    ,vlpercentual_desconto)
                VALUES
                    (rw_crapcop.cdcooper, idx, 6, 1, vr_perdesconto, vr_perdesconto);
                --            
            END IF;
        
            CLOSE cr_vinculacoes;
        
            OPEN cr_vinculacoes(rw_crapcop.cdcooper, 2, idx);
            FETCH cr_vinculacoes
                INTO rw_vinculacoes;
        
            IF cr_vinculacoes%NOTFOUND THEN
                --
                dbms_output.put_line('INSERINDO VINCULACOES PARA PJ ' || idx);
                --
                INSERT INTO tbrecip_vinculacao_parame_coop
                    (cdcooper
                    ,idvinculacao_reciproci
                    ,cdproduto
                    ,inpessoa
                    ,vlpercentual_peso
                    ,vlpercentual_desconto)
                VALUES
                    (rw_crapcop.cdcooper, idx, 6, 2, vr_perdesconto, vr_perdesconto);
                --            
            END IF;
        
            CLOSE cr_vinculacoes;
        
        END LOOP;
    END LOOP;
    --
    dbms_output.put_line('FIM');
    --
    COMMIT;
    --
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Erro: ' || SQLERRM);
        ROLLBACK;
END;
