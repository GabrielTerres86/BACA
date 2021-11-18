begin

	insert into tbgen_evento_soa (IDEVENTO, CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
	values (5025411, 1, 9329587, 4290768, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', '18/11/21 17:24:30,682528', null, null, null, null, null, '<?xml version="1.0" encoding="UTF-8"?>
	<Root>
		<convenioCredito>
			<cooperativa>
			  <codigo>1</codigo>
			</cooperativa>
			<numeroContrato>4290768</numeroContrato>
		</convenioCredito>
			<propostaContratoCredito>
				<emitente>
				  <contaCorrente>
					<codigoContaSemDigito>9329587</codigoContaSemDigito>
				  </contaCorrente>
				</emitente>
			</propostaContratoCredito>
			<lote>
				<tipoInteracao>
				  <codigo>INSTALLMENT_SETTLEMENT</codigo> 
				</tipoInteracao>
			</lote>
			<transacaoContaCorrente>
				<tipoInteracao>
				  <codigo>DEBITO</codigo>  
				</tipoInteracao>
			</transacaoContaCorrente>
			<parcela>
					<dataEfetivacao>2021-09-30T17:24:28</dataEfetivacao> 
					<dataVencimento>2022-07-10</dataVencimento>
					<identificador>723316</identificador>
					<valor>411.91</valor>
			</parcela>
			<motivoEnvio>REENVIARPAGTO</motivoEnvio>
			<interacaoGrafica>
				<dataAcaoUsuario>2021-11-12T17:24:30</dataAcaoUsuario>
			</interacaoGrafica>
	</Root>');

	insert into tbgen_evento_soa (IDEVENTO, CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
	values (5025412, 1, 9329587, 4290768, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', '18/11/21 17:24:31,019868', null, null, null, null, null, '<?xml version="1.0" encoding="UTF-8"?>
<Root>
	<convenioCredito>
		<cooperativa>
		  <codigo>1</codigo>
		</cooperativa>
		<numeroContrato>4290768</numeroContrato>
	</convenioCredito>
	<propostaContratoCredito>
		<emitente>
		  <contaCorrente>
			<codigoContaSemDigito>9329587</codigoContaSemDigito>
		  </contaCorrente>
		</emitente>
	</propostaContratoCredito>
	<lote>
		<tipoInteracao>
		  <codigo>INSTALLMENT_SETTLEMENT</codigo> 
		</tipoInteracao>
	</lote>
	<transacaoContaCorrente>
		<tipoInteracao>
		  <codigo>DEBITO</codigo>  
		</tipoInteracao>
	</transacaoContaCorrente>
	<parcela>
			<dataEfetivacao>2021-09-30T17:24:31</dataEfetivacao> 
			<dataVencimento>2022-08-10</dataVencimento>
			<identificador>723315</identificador>
			<valor>405.97</valor>
	</parcela>
	<motivoEnvio>REENVIARPAGTO</motivoEnvio>
	<interacaoGrafica>
		<dataAcaoUsuario>2021-11-12T17:24:31</dataAcaoUsuario>
	</interacaoGrafica>
</Root>');

	commit;

end;