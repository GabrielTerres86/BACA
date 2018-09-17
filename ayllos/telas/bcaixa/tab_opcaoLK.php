<? 
/*!
 * FONTE        : tab_opcaoLK.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 04/11/2011 
 * OBJETIVO     : Tabela que apresenta a consulta das opções L e K da tela BCAIXA
 * --------------
 * ALTERAÇÕES   : 17/04/2013 - Ajustes de layout de botoes para novo padrao (Lucas R.)
 * --------------
 */
 
?>

<form id="frmOpcaoLK" name="frmOpcaoLK" class="formulario" onSubmit="return false;" >

	<fieldset>
	<legend> <? echo utf8ToHtml('Lançamentos Extra-Sistema - Consultar') ?> </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Hist'); ?></th>
					<th><? echo utf8ToHtml('Descrição');  ?></th>
					<th><? echo utf8ToHtml('Complemento');  ?></th>
					<th><? echo utf8ToHtml('Docto');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
					<th><? echo utf8ToHtml('Seq');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $lanctos as $r ) { 
								
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdhistor'); ?></span>
								  <? echo getByTagName($r->tags,'cdhistor'); ?>
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'dshistor'); ?></span>
								  <? echo stringTabela(getByTagName($r->tags,'dshistor'),25,'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsdcompl'); ?></span>
								  <? echo stringTabela(getByTagName($r->tags,'dsdcompl'),17,'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdocmto'); ?></span>
								  <? echo getByTagName($r->tags,'nrdocmto'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vldocmto'); ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'vldocmto')); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrseqdig'); ?></span>
								  <? echo getByTagName($r->tags,'nrseqdig'); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:8px">
	<a href="#" class="botao" id="btVoltar" onClick="mostraOpcao(); return false;">Voltar</a>
	
</div>