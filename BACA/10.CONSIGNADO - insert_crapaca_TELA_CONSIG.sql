DECLARE
  v_nrseqrdr cecred.craprdr.nrseqrdr%type; 
BEGIN

  SELECT nrseqrdr 
    INTO v_nrseqrdr
    FROM cecred.craprdr  
   WHERE nmprogra = 'TELA_CONSIG';
  
  --Incluir a ação BUSCAR_VENC_PARCELA 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('BUSCAR_VENC_PARCELA'
    ,'TELA_CONSIG'
    ,'pc_busca_param_consig_web'
    ,'pr_cdempres'
    ,v_nrseqrdr);   
   
  INSERT INTO CRAPACA
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VAL_COOPER_CONSIGNADO'
    ,'TELA_CONSIG'
    ,'pc_val_cooper_consignado_web'
    ,'pr_cdcooper'
    ,v_nrseqrdr);
	
  --Incluir a ação BUSCAR_VENC_PARCELA 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('BUSCAR_VENC_PARCELA'
    ,'TELA_CONSIG'
    ,'pc_busca_param_consig_web'
    ,'pr_cdempres'
    ,v_nrseqrdr); 

 --Incluir a ação BUSCA_EMPRESA
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('BUSCA_EMPRESA'
    ,'TELA_CONSIG'
    ,'pc_busca_dados_emp_fis'
    ,''
    ,v_nrseqrdr);	
-------------------------------------------------------------------------
	
  INSERT INTO CRAPPRM
    (nmsistem 
    ,cdcooper 
    ,cdacesso 
    ,dstexprm 
    ,dsvlrprm)
  VALUES
    ('CRED'
    ,13
    ,'COOPER_CONSIGNADO'
    ,'Cooperativas que podem utilizar o consignado e suas validações'
    ,'S');	
    
  COMMIT;             
END; 

UPDATE CECRED.crapaca t
   set t.lstparam = null
 where t.nrseqrdr = (select R.NRSEQRDR from craprdr r where r.nmprogra = 'TELA_CONSIG')
   and T.NMDEACAO = 'HABILITAR_EMPR_CONSIG';   

UPDATE CECRED.crapaca t
   set t.lstparam = null
 where t.nrseqrdr = (select R.NRSEQRDR from craprdr r where r.nmprogra = 'TELA_CONSIG')
   and T.NMDEACAO = 'ALTERAR_EMPR_CONSIG'; 
 
COMMIT;
 
 
declare
  AUX number := 0;
begin 

 SELECT max(t.nrseqaca)
   INTO AUX
   FROM crapaca t 
  WHERE t.nmdeacao IN('INC_ALT_VENC_PARCELA','EXCLUIR_VENC_PARCELA','REPLICAR_VENC_PARCELA')
    AND t.nrseqrdr in(select r.nrseqrdr
                        from craprdr r 
                       where r.nmprogra = 'TELA_CONSIG');
 
  if AUX > 0 then
	 delete crapaca t 
	  where t.nmdeacao IN('INC_ALT_VENC_PARCELA','EXCLUIR_VENC_PARCELA','REPLICAR_VENC_PARCELA')
		and t.nrseqrdr in(select r.nrseqrdr
						   from craprdr r 
						  where r.nmprogra = 'TELA_CONSIG');     
  end if;
end;
					  
COMMIT;    
