DECLARE

  vr_existeprm	NUMBER;
  
  TYPE varray_cdcooper IS VARRAY(13) OF INTEGER;  
  v_arr_cdcooper varray_cdcooper := varray_cdcooper(1,2,5,6,7,8,9,10,11,12,13,14,16); -- 1-Viacredi, 2-Acredicoop, 5-Acentra, 6-Únilos, 7-Credcrea, 8-Credelesc ...
 
  TYPE varray_cdacesso IS VARRAY(6) OF VARCHAR2(500);  
  v_arr_cdacesso varray_cdacesso := varray_cdacesso('URI_ALIENA_GRAVAME'  , 'URI_CANCELA_GRAVAME', 
                                                    'URI_BAIXA_GRAVAME'   , 'URI_CONSULTA_GRAVAME', 
                                                    'URI_CONTRATO_GRAVAME', 'URI_IMG_CONTRATO_GRAVAME');                                                   
  TYPE varray_dstexprm IS VARRAY(6) OF VARCHAR2(500);  
  v_arr_dstexprm varray_dstexprm := varray_dstexprm('URI para Alienação do GRAVAME' , 'URI para Cancelamento do GRAVAME',
                                                    'URI para Baixa do GRAVAME'     , 'URI para Consulta do GRAVAME', 
                                                    'URI para Contrato do GRAVAME'  , 'URI para IMG do Contrato do GRAVAME'); 
  TYPE varray_dsvlrprm IS VARRAY(6) OF VARCHAR2(500);  
  v_arr_dsvlrprm varray_dsvlrprm := varray_dsvlrprm('/osb-soa/GarantiaVeiculoRestService/v1/EfetivarAlienacaoGravames'    , '/osb-soa/GarantiaVeiculoRestService/v1/EfetivarCancelamentoGravames',
                                                    '/osb-soa/GarantiaVeiculoRestService/v1/EfetivarDesalienacaoGravames' , '/osb-soa/GarantiaVeiculoRestService/v1/ObterSituacaoGravames', 
                                                    '/osb-soa/GarantiaVeiculoRestService/v1/RegistrarContratoGravames'    , '/osb-soa/GarantiaVeiculoRestService/v1/EnviarImagemContratoGravames'); 
  v_teste varchar(500);


BEGIN
	
  SELECT Count(1) INTO vr_existeprm FROM CECRED.crapprm 
  WHERE  cdacesso IN (v_arr_cdacesso(1),v_arr_cdacesso(2),v_arr_cdacesso(3),v_arr_cdacesso(4),v_arr_cdacesso(5),v_arr_cdacesso(6) )
  AND    nmsistem = 'CRED';
 
  IF (vr_existeprm > 0) THEN  
     DELETE FROM CECRED.crapprm 
     WHERE  cdacesso IN (v_arr_cdacesso(1),v_arr_cdacesso(2),v_arr_cdacesso(3),v_arr_cdacesso(4),v_arr_cdacesso(5),v_arr_cdacesso(6) )
     AND    nmsistem = 'CRED';	 
  END IF;
 
  FOR v_loop_cdcooper IN 1..v_arr_cdcooper.count LOOP
	  
	  FOR v_loop_cdacesso IN 1..v_arr_cdacesso.count LOOP		  
	  
		   INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
		        VALUES ('CRED'
			            ,v_arr_cdcooper(v_loop_cdcooper) -- Código da cooperativa
			            ,v_arr_cdacesso(v_loop_cdacesso) -- Código do acesso
			            ,v_arr_dstexprm(v_loop_cdacesso) -- Descrição da ação do consumo da api
			            ,v_arr_dsvlrprm(v_loop_cdacesso)
			           ); -- URI do GRAVAME			  
  
		   -- :::::::::::::  TESTE ::::::::::::::
		   -- v_teste := 'INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)'||
		   --		      'VALUES (''CRED'','||
		   --			           v_arr_cdcooper(v_loop_cdcooper)||','||         -- Código da cooperativa
		   --			           ''''||v_arr_cdacesso(v_loop_cdacesso)||''','|| -- Código do acesso
		   --			           ''''||v_arr_dstexprm(v_loop_cdacesso)||''','|| -- Descrição da ação do consumo da api
		   --			           ''''||v_arr_dsvlrprm(v_loop_cdacesso)||''')';  -- URI do GRAVAME'
		   --	             
           -- dbms_output.put_line(v_teste);

      END LOOP;
     
  END LOOP;
 
  COMMIT;
 
  EXCEPTION WHEN OTHERS THEN ROLLBACK;            

END; 
 





 