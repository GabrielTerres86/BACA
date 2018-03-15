<? 
/*!
 * FONTE        : form_consulta_ted.php
 * CRIAÇÃO      : Helinton Steffens - (Supero)
 * DATA CRIAÇÃO : 14/03/2018 
 * OBJETIVO     : Tabela que apresenta as TED recebidas
 */	
?>

<form id="frmTabela" class="formulario" >
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Cart&oacuterio'); ?></th>
					<th><? echo utf8ToHtml('Nome do remetente');  ?></th>
					<th><? echo utf8ToHtml('CPF/CNPJ');  ?></th>
					<th><? echo utf8ToHtml('Banco');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Data recebimento');  ?></th>
                    <th><? echo utf8ToHtml('Valor');  ?></th>
                    <th><? echo utf8ToHtml('Cidade');  ?></th>
                    <th><? echo utf8ToHtml('UF');  ?></th>
                    <th><? echo utf8ToHtml('Status');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registro as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'dscartor') ?></span>
							      <? echo getByTagName($r->tags,'dscartor') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nmremet') ?></span>
							      <? echo getByTagName($r->tags,'nmremet') ?>
						</td>
                        <td><span><? echo getByTagName($r->tags,'nrdocmto') ?></span>
							      <? echo getByTagName($r->tags,'nrdocmto') ?>
						</td>
                        <td><span><? echo getByTagName($r->tags,'nrdconta') ?></span>
							      <? echo getByTagName($r->tags,'nrdconta') ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtrecebi')) ?></span>
							      <? echo getByTagName($r->tags,'dtrecebi') ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vldpagto'),'MOEDA')  ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vldpagto')) ?>
						</td>
                        <td><span><? echo getByTagName($r->tags,'dscidade') ?></span>
							      <? echo getByTagName($r->tags,'dscidade') ?>
						</td>
                        <td><span><? echo getByTagName($r->tags,'dsestado') ?></span>
							      <? echo getByTagName($r->tags,'dsestado') ?>
						</td>
                        <td><span><? echo getByTagName($r->tags,'indconci') ?></span>
							      <? echo getByTagName($r->tags,'indconci') ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
</form>

<div id="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<?php
	if ( $qtregist > 0 ) {
	?>
		<a href="#" class="botao" onclick="buscaConsulta('log'); return false;">Exportar PDF</a>
		<a href="#" class="botao" onclick="buscaConsulta('instrucoes'); return false;">Exportar CSV</a>
		<a href="#" class="botao" onclick="buscaExportar(); return false;">Devolver</a>
		<a href="#" class="botao" onclick="geraCartaAnuencia(); return false;">Extornar</a>
	<?php
	}
	?>
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".$operacao."','".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".$operacao."','".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divRegistros','#divTela').formataTabela();
	
</script>