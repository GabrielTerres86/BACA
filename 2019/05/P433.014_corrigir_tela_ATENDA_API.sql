/******************************************************************************************************** 
  Baca para criar TELA_ATENDA_API
  -----------------
   Autor: André Clemer (Supero)                                 Data: 25/02/2019
  -----------------
*********************************************************************************************************/

DECLARE
    vr_rsprogra VARCHAR2(242);
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;

    CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS
        SELECT * FROM craprdr WHERE craprdr.nmprogra = pr_nmprogra;
    rw_craprdr cr_craprdr%ROWTYPE;

BEGIN
    vr_rsprogra := 'TELA_ATENDA_API';

    -- Mensageria
    OPEN cr_craprdr(pr_nmprogra => vr_rsprogra);
    FETCH cr_craprdr
        INTO rw_craprdr;

    -- Verifica se existe a tela
    IF cr_craprdr%NOTFOUND THEN
        
        dbms_output.put_line('Insere CRAPRDR -> ' || vr_rsprogra);
    
        -- Insere tela do ayllos web
        INSERT INTO craprdr (nmprogra, dtsolici) VALUES (vr_rsprogra, SYSDATE) RETURNING nrseqrdr INTO vr_nrseqrdr;
    ELSE
        vr_nrseqrdr := rw_craprdr.nrseqrdr;
    END IF;
    
    -- Se não encontrar
    CLOSE cr_craprdr;
    
    -- Excluir o registro incluso de forma errada
    DELETE crapaca t WHERE t.nmdeacao = 'GRAVA_SERVICOS_COOP';
    
    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('GRAVA_SERVICOS_COOP'
        ,'TELA_ATENDA_API'
        ,'pc_grava_servicos_coop'
        ,'pr_nrdconta,pr_idservico_api,pr_dtadesao,pr_idsituacao_adesao,pr_tp_autorizacao,pr_ls_finalidades,pr_ls_desenvolvedores,pr_cddopcao'
        ,vr_nrseqrdr);
		
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Erro: ' || SQLERRM);
        ROLLBACK;
END;
