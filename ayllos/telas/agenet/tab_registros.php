<?php
/*!
 * FONTE        : tab_registros.php						Última alteração: 15/07/2016
 * CRIAÇÃO      : Jonathan - RKAM
 * DATA CRIAÇÃO : 17/11/2015
 * OBJETIVO     : Tabela que apresenta a consulta de agendamentos da tela AGENET
 * --------------
 * ALTERAÇÕES   : 25/04/2016 - Ajuste para atender as solicitações do projeto M 117(Adriano - M117).
 *                15/07/2016 - Inclusao do nrdconta para ser passado por parametro para o cancelamento (Carlos)
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *			      31/11/2017 - Exibir TEDs Canceladas devido a fraude PRJ335 - Analise de fraude(Odirlei-AMcom)
 * --------------
 */ 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmAgendamentos" name="frmAgendamentos" class="formulario" style="display:none;">

	<fieldset id="fsetAgendamentos" name="fsetAgendamentos" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Agendamentos"; ?></legend>
		
		<div class="divRegistros">
		
			<table>
				<thead>
					<tr>
						<th>PA</th>
						<th>Conta/dv</th>
						<th>Data</th>
						<th>Tipo</th>
						<th>Valor</th>
						<th>Situa&ccedil;&atilde;o</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $result ) {    ?>
						<tr onClick="selecionaAgendamentos(this);" >	
							<td><span><? echo getByTagName($result->tags,'cdagenci'); ?></span> <? echo getByTagName($result->tags,'cdagenci'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nrdconta'); ?></span> <? echo getByTagName($result->tags,'nrdconta'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dtmvtopg'); ?></span> <? echo getByTagName($result->tags,'dtmvtopg'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dstiptra'); ?></span> <? echo getByTagName($result->tags,'dstiptra'); ?> </td>
							<td><span><? echo str_replace(",",".",getByTagName($result->tags,'vllanaut')); ?></span><? echo number_format(str_replace(",",".",getByTagName($result->tags,'vllanaut')),2,",","."); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dssitlau'); ?></span><? echo getByTagName($result->tags,'dssitlau'); ?> </td>
							<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($result->tags,'nrdconta'); ?>" />
							<input type="hidden" id="dttransa" name="dttransa" value="<? echo getByTagName($result->tags,'dttransa'); ?>" />
							<input type="hidden" id="hrtransa" name="hrtransa" value="<? echo getByTagName($result->tags,'hrtransa'); ?>" />
							<input type="hidden" id="dstitdda" name="dstitdda" value="<? echo getByTagName($result->tags,'dstitdda'); ?>" />
							<input type="hidden" id="dstransa" name="dstransa" value="<? echo getByTagName($result->tags,'dstransa'); ?>" />
							<input type="hidden" id="dstiptra" name="dstiptra" value="<? echo getByTagName($result->tags,'dstiptra'); ?>" />
							<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($result->tags,'dtmvtolt'); ?>" />
							<input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo getByTagName($result->tags,'nrdocmto'); ?>" />
							<input type="hidden" id="insitlau" name="insitlau" value="<? echo getByTagName($result->tags,'insitlau'); ?>" />
							<input type="hidden" id="vllanaut" name="vllanaut" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vllanaut')),2,",","."); ?>" />
							<input type="hidden" id="tpcaptura" name="tpcaptura" value="<? echo getByTagName($result->tags,'tpcaptura'); ?>" />
							<input type="hidden" id="dstpcaptura" name="dstpcaptura" value="<? echo getByTagName($result->tags,'dstpcaptura'); ?>" />
							<input type="hidden" id="dslinha_digitavel" name="dslinha_digitavel" value="<? echo getByTagName($result->tags,'dslinha_digitavel'); ?>" />
							<input type="hidden" id="dsnome_fone" name="dsnome_fone" value="<? echo getByTagName($result->tags,'dsnome_fone'); ?>" />
							<input type="hidden" id="dtapuracao" name="dtapuracao" value="<? echo getByTagName($result->tags,'dtapuracao'); ?>" />
							<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($result->tags,'nrcpfcgc'); ?>" />
							<input type="hidden" id="cdtributo" name="cdtributo" value="<? echo getByTagName($result->tags,'cdtributo'); ?>" />
							<input type="hidden" id="nrrefere" name="nrrefere" value="<? echo getByTagName($result->tags,'nrrefere'); ?>" />
							<input type="hidden" id="dtvencto" name="dtvencto" value="<? echo getByTagName($result->tags,'dtvencto'); ?>" />
							<input type="hidden" id="vlprincipal" name="vlprincipal" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlprincipal')),2,",","."); ?>" />
							<input type="hidden" id="vlmulta" name="vlmulta" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlmulta')),2,",","."); ?>" />
							<input type="hidden" id="vljuros" name="vljuros" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vljuros')),2,",","."); ?>" />
							<input type="hidden" id="vlreceita_bruta" name="vlreceita_bruta" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlreceita_bruta')),2,",","."); ?>" />
							<input type="hidden" id="vlpercentual" name="vlpercentual" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlpercentual')),2,",","."); ?>" />
						    <input type="hidden" id="dsobserv" name="dsobserv" value="<? echo getByTagName($result->tags,'dsobserv'); ?>" />
						</tr>	
					<? } ?>
				</tbody>	
			</table>
		</div>
		<div id="divRegistrosRodape" class="divRegistrosRodape">
			<table>	
				<tr>
					<td>
						<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
						<? if ($nriniseq > 1){ ?>
							   <a class="paginacaoAnt"><<< Anterior</a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
					<td>
						<? if (isset($nriniseq)) { ?>
							   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
							<? } ?>
						/ Total: <? echo number_format(str_replace(",",".",$vllanaut ),2,",","."); ?>
					</td>
					<td>
						<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
							  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
				</tr>
			</table>
		</div>	
	</fieldset>
	
	<fieldset id="fsetAgendamentoConta" name="fsetAgendamentoConta" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend><? echo "Informa&ccedil;&atilde;o"; ?></legend>
		
		<label for="dttransa"><? echo utf8ToHtml('Data Cadastro:') ?></label>
		<input type="text" id="dttransa" name="dttransa"/>
		
		<label for="hrtransa"><? echo utf8ToHtml('Hora Cadastro:') ?></label>
		<input type="text" id="hrtransa" name="hrtransa"/>
		
		<input type="text" id="dstitdda" name="dstitdda"/>
		
	</fieldset>
	
	<fieldset id="fsetAgendamentoContaDestino" name="fsetAgendamentoContaDestino" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend><? echo "Informa&ccedil;&atilde;o"; ?></legend>
		
		<label for="dstransa"><? echo utf8ToHtml('Destino:') ?></label>
		<input type="text" id="dstransa" name="dstransa"/>
		
		<label for="dttransa"><? echo utf8ToHtml('Data Cadastro:') ?></label>
		<input type="text" id="dttransa" name="dttransa"/>
		
		<label for="hrtransa"><? echo utf8ToHtml('Hora Cadastro:') ?></label>
		<input type="text" id="hrtransa" name="hrtransa"/>
		
		<input type="text" id="dstitdda" name="dstitdda"/>
        
        <label for="dsobserv"><? echo utf8ToHtml('Observa&ccedil;&atilde;o:') ?></label>
		<input type="text" id="dsobserv" name="dsobserv"/>
		
	</fieldset>
	
	<fieldset id="fsetAgendamentoLinhaDig" name="fsetAgendamentoLinhaDig" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend><? echo "Informa&ccedil;&atilde;o"; ?></legend>
		
		<label for="dstransa"><? echo utf8ToHtml('Linha Digit&aacute;vel:') ?></label>
		<input type="text" id="dstransa" name="dstransa"/>
		
		<label for="dttransa"><? echo utf8ToHtml('Data Cadastro:') ?></label>
		<input type="text" id="dttransa" name="dttransa"/>
		
		<label for="hrtransa"><? echo utf8ToHtml('Hora Cadastro:') ?></label>
		<input type="text" id="hrtransa" name="hrtransa"/>
		
		<input type="text" id="dstitdda" name="dstitdda"/>
		
	</fieldset>
	
	<fieldset id="fsetAgendamentoDarfDas" name="fsetAgendamentoDarfDas" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend><? echo "Informa&ccedil;&atilde;o"; ?></legend>
		
		<label for="dstpcaptura"><? echo utf8ToHtml('Tipo de Captura:') ?></label>
		<input type="text" id="dstpcaptura" name="dstpcaptura"/>

		<label for="dsnome_fone"><? echo utf8ToHtml('Nome / Telefone:') ?></label>
		<input type="text" id="dsnome_fone" name="dsnome_fone"/>
		
		<div id="divDarfDasLinDig" name="divDarfDasLinDig" style="display:none">
			<label for="dslinha_digitavel"><? echo utf8ToHtml('Linha Digitável:') ?></label>
			<input type="text" id="dslinha_digitavel" name="dslinha_digitavel"/>
		</div>
		
		<div id="divDarfDasManual" name="divDarfDasManual" style="display:none">
			<label for="nrcpfcgc"><? echo utf8ToHtml('CPF / CNPJ:') ?></label>
			<input type="text" id="nrcpfcgc" name="nrcpfcgc"/>

			<label for="dtapuracao"><? echo utf8ToHtml('Período de Apuração:') ?></label>
			<input type="text" id="dtapuracao" name="dtapuracao"/>

			<label for="dtvencto"><? echo utf8ToHtml('Data de Vencimento:') ?></label>
			<input type="text" id="dtvencto" name="dtvencto"/>

			<label for="cdtributo"><? echo utf8ToHtml('Código da Receita:') ?></label>
			<input type="text" id="cdtributo" name="cdtributo"/>

			<label for="nrrefere"><? echo utf8ToHtml('Número de Referência:') ?></label>
			<input type="text" id="nrrefere" name="nrrefere"/>

			<label for="vlreceita_bruta"><? echo utf8ToHtml('Receita Bruta Acumulada:') ?></label>
			<input type="text" id="vlreceita_bruta" name="vlreceita_bruta"/>

			<label for="vlpercentual"><? echo utf8ToHtml('Percentual:') ?></label>
			<input type="text" id="vlpercentual" name="vlpercentual"/>

			<label for="vlprincipal"><? echo utf8ToHtml('Valor Principal:') ?></label>
			<input type="text" id="vlprincipal" name="vlprincipal"/>

			<label for="vlmulta"><? echo utf8ToHtml('Valor da Multa:') ?></label>
			<input type="text" id="vlmulta" name="vlmulta"/>

			<label for="vljuros"><? echo utf8ToHtml('Valor dos Juros:') ?></label>
			<input type="text" id="vljuros" name="vljuros"/>

			<label for="vllanaut"><? echo utf8ToHtml('Valor Total:') ?></label>
			<input type="text" id="vllanaut" name="vllanaut"/>
		</div>
		
		<label for="dttransa"><? echo utf8ToHtml('Data Cadastro:') ?></label>
		<input type="text" id="dttransa" name="dttransa"/>
		
		<label for="hrtransa"><? echo utf8ToHtml('Hora Cadastro:') ?></label>
		<input type="text" id="hrtransa" name="hrtransa"/>
		
	</fieldset>
	
	<fieldset id="fsetAgendamentoRecarga" name="fsetAgendamentoRecarga" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend><? echo "Informa&ccedil;&atilde;o"; ?></legend>
		
		<label for="dstransa"><? echo utf8ToHtml('Telefone:') ?></label>
		<input type="text" id="dstransa" name="dstransa"/>
		
		<label for="dttransa"><? echo utf8ToHtml('Data Cadastro:') ?></label>
		<input type="text" id="dttransa" name="dttransa"/>
		
		<label for="hrtransa"><? echo utf8ToHtml('Hora Cadastro:') ?></label>
		<input type="text" id="hrtransa" name="hrtransa"/>
		
	</fieldset>
</form>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscaAgendamentos(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscaAgendamentos(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistros','#divTabela').formataRodapePesquisa();
			
</script>