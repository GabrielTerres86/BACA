DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'DDA0002';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('DDA0002', SYSDATE)
       RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (
         nmdeacao
         , nmpackag
         , nmproced
         , lstparam
         , nrseqrdr
  ) VALUES (
        'ADICIONAR_AGREGADO_COBRAN'
        , 'DDA0002'
        , 'pccobran_add_agregado_web'
        , 'pr_cdcooperativa, pr_nrdconta, pr_nrcpfcgcpagdr, pr_nmpagdr, pr_inpessoapagdr, pr_nrcpfcgcagrg, pr_nmagrg, pr_inpessoaagrg, pr_idsituacao, pr_dtcadastro, pr_dtretorno, pr_dtadesao, pr_dtcancelamento, pr_dsobserv'
        , vr_nrseqrdr);
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a DDA0002 criado com sucesso!');
  
END;