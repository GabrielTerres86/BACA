BEGIN
  -- Motivo para decsontos de títulos
  INSERT INTO tbgen_motivo(idmotivo
						  ,dsmotivo
						  ,cdproduto
						  ,flgreserva_sistema
						  ,flgativo
						  ,flgtipo
						  ,flgexibe)
			  VALUES(78
					,'Desconto de titulo em atraso'
					,25
					,0
					,1
					,0
					,1);

  INSERT INTO tbgen_motivo(idmotivo
						  ,dsmotivo
						  ,cdproduto
						  ,flgreserva_sistema
						  ,flgativo
						  ,flgtipo
						  ,flgexibe)
			  VALUES(79
					,'Bloqueio manual'
					,25
					,1
					,1
					,0
					,1);

  COMMIT;
END;
