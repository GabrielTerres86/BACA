<? 
/*!
 * FONTE        : contrato_tab.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 29/01/2019
 * OBJETIVO     : Tabela que apresenta os contratos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */    
?>
<div id="divContrato">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Contrato'); ?></th>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Tipo'); ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrcontrato') ?></span>
							<? echo mascara(getByTagName($r->tags,'nrcontrato'),'#.###.###.###') ?>
							<input type="hidden" id="nrctremp" name="nrctremp" value="<? echo mascara(getByTagName($r->tags,'nrcontrato'),'#.###.###.###') ?>" />
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) ?></span>
								<? echo getByTagName($r->tags,'dtmvtolt') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'tpcontrato') ?></span>
								<? echo getByTagName($r->tags,'tpcontrato') ?>
						</td>
					</tr>
			<? } ?>
			</tbody>
		</table>
	</div>
</div>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); nrctremp.focus(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaContrato(); return false;">Continuar</a>
</div>