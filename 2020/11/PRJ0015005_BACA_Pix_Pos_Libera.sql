begin
     
	 /* Ajuste labels fases */
     update pix.tbpix_tipo_fase
	   set nmfase = 'Valida��o dos cr�ditos do cooperado'
	 where idfase = 19;

       update pix.tbpix_tipo_fase
	   set nmfase = 'Retorno An�lise OFSAA (Autom�tico)'
	 where idfase = 12;

	/* Nova fase */
       insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (20, 'Cancelamento An�lise Manual', 'A');

       insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                                         values (49,'P',20,35,'S',null); 

    /* Ajustes chaves PJ */
	update tbpix_chave_enderecamento ce
	   set ce.idseqttl = 1
	 where ce.idseqttl > 1
	   and exists(select 1
					from tbpix_crapass a
				   where a.cdcooper = ce.cdcooper
					 and a.nrdconta = ce.nrdconta
					 and a.INPESSOA > 1);


      commit;

end;