<?
/*!
 * FONTE        : form_tabela.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 28/02/2012
 * OBJETIVO     : Tabela para visualizacao dos dados
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 * --------------
 */
?>


		
<div class="divDados">
	<fieldset>
		
	<div class="divRegistros">
		
			<table>
				<thead>
					<tr>
						<th><? echo utf8ToHtml('PA'); ?></th>
						<th><? echo utf8ToHtml('Lote');  ?></th>
						<th><? echo utf8ToHtml('Conta/dv');  ?></th>
						<th><? echo utf8ToHtml('Titular');  ?></th>
						<th><? echo utf8ToHtml('Valor (R$)');  ?></th>
						<th><? echo utf8ToHtml('Docto');  ?></th>
						<th><? echo utf8ToHtml('Data');  ?></th>
						<th><? echo utf8ToHtml('Oper.');  ?></th>
						<th><? echo utf8ToHtml('COAF');  ?></th>
					</tr>
				</thead>
				<tbody>
		
	<?php
			
	for ($i = 0; $i < $dados_count; $i++){
		
		$cdagenci = getByTagName($dados[$i]->tags,"CDAGENCI");
		$nrdolote = getByTagName($dados[$i]->tags,"NRDOLOTE");
		$nrdconta = getByTagName($dados[$i]->tags,"NRDCONTA");
		$nmprimtl = substr(getByTagName($dados[$i]->tags,"NMPRIMTL"), 0, 10);
		$vllanmto = getByTagName($dados[$i]->tags,"VLLANMTO");
		$nrdocmto = getByTagName($dados[$i]->tags,"NRDOCMTO");
		$dtmvtolt = getByTagName($dados[$i]->tags,"DTMVTOLT");
		$tpoperac = getByTagName($dados[$i]->tags,"TPOPERAC");
		
		if (getByTagName($dados[$i]->tags,"SISBACEN") == "yes")
			$sisbacen = "SIM";
		else
			$sisbacen = "NAO";
			
		?>
		<tr id="trArquivosProcessados<?php echo $i; ?>" style="cursor: pointer;">
			<td><?php echo $cdagenci; ?>
			</td>
			<td><?php echo $nrdolote; ?>
			</td>
			<td><?php echo $nrdconta; ?>
			</td>
			<td><?php echo $nmprimtl; ?>
			</td>
			<td><?php echo $vllanmto; ?>
			</td>
			<td><?php echo $nrdocmto; ?>
			</td>
			<td><?php echo $dtmvtolt; ?>
			</td>
			<td><?php echo $tpoperac; ?>
			</td>
			<td><?php echo $sisbacen; ?>
			</td>
		</tr>
	<?
	}

	?>
		
					</tbody>
				</table>
	</div>
	</fieldset>

</div>
<?php
if ($nmdivform != '"#divReimprimeControle"') {

?>

	<div id="divPesquisaRodape<?php echo $aux_id; ?>" class="divPesquisaRodape">
	<table cellspacing="3px" cellpadding="3px">	
		<tr>
			<td>
				<?
					if (isset($total_registros) and $total_registros == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt' align="left"><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				<div width="350px" style="margin-left:auto; margin-right:auto;">
				<?
					if (isset($nriniseq)) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $total_registros) { echo $total_registros; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $total_registros; ?><?
					}
				?>
				</div>
			</td>
			<td>
				<?
					// Se a paginação não está na última página, exibe botão proximo
					if ($total_registros > ($nriniseq + $nrregist - 1)) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
	</div>
				
	<?php
	}
	?>


<script type="text/javascript">

nmrescop = '<? echo getByTagName($dados[0]->tags,"NMRESCOP"); ?>';
cdopecxa = '<? echo getByTagName($dados[0]->tags,"CDOPECXA"); ?>';
nrdcaixa = '<? echo getByTagName($dados[0]->tags,"NRDCAIXA"); ?>';
nrseqaut = '<? echo getByTagName($dados[0]->tags,"NRSEQAUT"); ?>';
nrdctabb = '<? echo getByTagName($dados[0]->tags,"NRDCTABB"); ?>';
<? 
if ($tpoperac == "DEPOSITO") {
?>
	tpoperac = '1';
<?
} else {
?>
	tpoperac = '2';
<?
}

if ($nmdivform == '"#divConsultaPac"') {
?>

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		consultaTransacoesPac(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});

	$('a.paginacaoProx').unbind('click').bind('click', function() {
		consultaTransacoesPac(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});
<?
} else if ($nmdivform == '"#divConsulta"') {
?>
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		consultaTransacoes(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});

	$('a.paginacaoProx').unbind('click').bind('click', function() {
		consultaTransacoes(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});
<?
}
?>

</script>



