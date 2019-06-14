<? 
/*!
 * FONTE        : form_consulta_custas.php
 * CRIAÇÃO      : André Clemer - (Supero)
 * DATA CRIAÇÃO : 29/03/2018 
 * OBJETIVO     : Tabela que apresenta as custas
 */	
?>

<form id="frmTabela" class="formulario" >
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th width="40"><? echo utf8ToHtml('Data');  ?></th>
                    <th width="80"><? echo utf8ToHtml('Coop.');  ?></th>
                    <th width="100"><? echo utf8ToHtml('Cartório');  ?></th>
                    <th width="20"><? echo utf8ToHtml('UF');  ?></th>
                    <th width="40"><? echo utf8ToHtml('Vlr. Cart.');  ?></th>
                    <th width="40"><? echo utf8ToHtml('Vlr. Dist.');  ?></th>
					<th width="40"><? echo utf8ToHtml('Tot. Saldo');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? for ($x = 0; $x < (count($registros) - 1); $x++) { $r = $registros[$x]; ?>
					<tr>
						
						<td>
							      <? echo getByTagName($r->tags,'dtmvtolt') ?>
								  <input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($r->tags,'dtmvtolt') ?>" />
								  <input type="hidden" id="nmrescop" name="nmrescop" value="<? echo getByTagName($r->tags,'nmrescop') ?>" />
								  <input type="hidden" id="nmcartorio" name="nmcartorio" value="<? echo getByTagName($r->tags,'nmcartorio') ?>" />
								  <input type="hidden" id="cdestado" name="cdestado" value="<? echo getByTagName($r->tags,'cdestado') ?>" />
								  <input type="hidden" id="custas_cartorarias" name="custas_cartorarias" value="<? echo getByTagName($r->tags,'custas_cartorarias') ?>" />
								  <input type="hidden" id="custas_distribuidor" name="custas_distribuidor" value="<? echo getByTagName($r->tags,'custas_distribuidor') ?>" />
								  <input type="hidden" id="nrnosnum" name="nrnosnum" value="<? echo getByTagName($r->tags,'nrnosnum') ?>" />
								  <input type="hidden" id="total_despesas" name="total_despesas" value="<? echo getByTagName($r->tags,'total_despesas') ?>" />
						</td>
                        <td>
							      <? echo getByTagName($r->tags,'nmrescop') ?>
						</td>
                        <td>
							      <? echo getByTagName($r->tags,'nmcartorio') ?>
						</td>
						<td>
							      <? echo getByTagName($r->tags,'cdestado') ?>
						</td>
						<td>
							      <? echo number_format(getByTagName($r->tags,'custas_cartorarias'),2,',','.') ?>
						</td>
						<td>
							      <? echo number_format(getByTagName($r->tags,'custas_distribuidor'),2,',','.') ?>
						</td>
						<td>
							      <? echo number_format(getByTagName($r->tags,'total_despesas'),2,',','.') ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	<div id="linha1">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Nosso Nro.:'); ?></li>
	<li id="nrnosnum"></li>
	</ul>
	</div>

</form>

<div id="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<?php
	if (count($registros) > 0 ) {
	?>
		<a href="#" class="botao" onclick="exportarConsultaPDF(); return false;" ><? echo utf8ToHtml('Exportar PDF'); ?></a>
		<a href="#" class="botao" onclick="exportarConsultaCSV(); return false;" ><? echo utf8ToHtml('Exportar CSV'); ?></a>
	<?php
	}
	?>
</div>

<script type="text/javascript">
	var divRegistros = $('.divRegistros', '#divFormulario');
	var tabela = $('table', divRegistros);

	var length = ['40px','80px','100px','20px','40px','40px','40px'];

	tabela.formataTabela([[0, 0]], length);
	formataOpcaoR();

	// seleciona o registro que ? clicado
    $('table > tbody > tr', divRegistros).die("click").live("click", function () {
        $('#nrnosnum', '.complemento').html($(this).find('#nrnosnum').val());
    });
</script>