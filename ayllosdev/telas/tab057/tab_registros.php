<? 
/*!
 * FONTE        : tab_registros.php
 * DATA CRIAÇÃO : 26/01/2017
 * OBJETIVO     : Tabela que apresenta a consulta TAB057
 * --------------
 * ALTERAÇÕES   : 
 *
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<fieldset id="Informacoes">

	<legend><? echo utf8ToHtml('Arrecadações'); ?></legend>
	
	<div class="divRegistros">
	
	    <table>
			<thead>
 			    <tr>
					<th><? echo utf8ToHtml('Coop.'); ?></th>
					<th><? echo utf8ToHtml('Convênio'); ?></th>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Qtd.'); ?></th>
					<th><? echo utf8ToHtml('Arrec.'); ?></th>
					<th><? echo utf8ToHtml('Tarifa'); ?></th>
					<th><? echo utf8ToHtml('Pagar'); ?></th>
			    </tr>
			</thead>
			<tbody>
				<? foreach( $registros as $result ) {    ?>
				    <tr>	
						<td><span><? echo getByTagName($result->tags,'nmrescop'); ?></span> <? echo getByTagName($result->tags,'nmrescop'); ?> </td>
						<td><span><? echo getByTagName($result->tags,'cdconven'); ?></span> <? echo getByTagName($result->tags,'cdconven'); ?> </td>
						<td><span><? echo getByTagName($result->tags,'dtmvtolt'); ?></span> <? echo getByTagName($result->tags,'dtmvtolt'); ?> </td>
						<td><span><? echo getByTagName($result->tags,'qtdoctos'); ?></span> <? echo getByTagName($result->tags,'qtdoctos'); ?> </td>
						<td><span><? echo getByTagName($result->tags,'vldoctos'); ?></span> <? echo number_format(str_replace(",",".",getByTagName($result->tags,'vldoctos')),2,",","."); ?> </td>
						<td><span><? echo getByTagName($result->tags,'vltarifa'); ?></span> <? echo number_format(str_replace(",",".",getByTagName($result->tags,'vltarifa')),2,",","."); ?> </td>
						<td><span><? echo getByTagName($result->tags,'vlapagar'); ?></span> <? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlapagar')),2,",","."); ?> </td>
						<input type="hidden" id="nrsequen" name="nrsequen" value="<? echo getByTagName($result->tags,'nrsequen') ?>" />
						<input type="hidden" id="nmarquiv" name="nmarquiv" value="<? echo getByTagName($result->tags,'nmarquiv') ?>" />		
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

<script type="text/javascript">
	$('#btVoltar','#divBotoes').css('display','inline');
	$('#btSalvar','#divBotoes').css('display','none');
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		consultaBancoob(<? echo ($nriniseq - $nrregist);?>,<?php echo $nrregist;?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		consultaBancoob(<? echo ($nriniseq + $nrregist);?>,<?php echo $nrregist;?>);
		
	});		
	$('#divPesquisaRodape','#divConsulta').formataRodapePesquisa();
	
	controlaLayout("1");
</script>

