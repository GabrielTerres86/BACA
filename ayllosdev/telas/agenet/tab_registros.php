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
						<tr>	
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
