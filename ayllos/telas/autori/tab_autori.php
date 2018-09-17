<? 
/*!
 * FONTE        : tab_autori.php
 * CRIAÇÃO      : Rogérius Militão - (DB1)
 * DATA CRIAÇÃO : 16/05/2011 
 * OBJETIVO     : Tabela que apresenda as autorizações de debito em conta
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Migrado para o Novo Layout (Lucas).
 ----------------
 * 				  19/05/2014 - Ajustes referentes ao Projeto debito Automatico
 *							   Softdesk 148330 (Lucas R.)
 */	
?>

<fieldset id='tabConteudo'>

	<legend><? echo utf8ToHtml('Autorizações') ?></legend>
	
	<div class="divRegistros" >
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Convênio')?></th>
					<th><? echo utf8ToHtml('Referência')?></th>
					<th>Dt. Autor. </th>
					<th>Dt. Canc.  </th>
					<th>Ult. Deb.  </th>
				</tr>

			</thead>
			<tbody>
				<? foreach( $registros as $autorizacao ) { ?>
					<tr><td>
							<span><? echo getByTagName($autorizacao->tags,'dshistor') ?></span>
							<? echo stringTabela(getByTagName($autorizacao->tags,'dshistor'), 13, 'palavra') ?>
						</td>
						<td><? echo getByTagName($autorizacao->tags,'cdrefere') ?></td>
						<td>
							<span><? echo dataParaTimestamp(getByTagName($autorizacao->tags,'dtautori')) ?></span>
							<? echo getByTagName($autorizacao->tags,'dtautori') ?>
						</td>
						<td>
							<span><? echo dataParaTimestamp(getByTagName($autorizacao->tags,'dtcancel')) ?></span>
							<? echo getByTagName($autorizacao->tags,'dtcancel') ?>
						</td>
						<td>
							<span><? echo dataParaTimestamp(getByTagName($autorizacao->tags,'dtultdeb')) ?></span>
							<? echo getByTagName($autorizacao->tags,'dtultdeb') ?>
						</td>
					</tr>
				<? } ?>
				</tbody>
		</table>
	</div> 


<? if ($operacao == 'I6') { ?>	
<div id="divBotoes" style='border-top:1px solid #777'>
	<a href="#" class="botao" id="btIncluir" onClick="controlaOperacao('I1'); return false;">Incluir</a>
</div>	
<? }else{ ?>
	<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	</div>
<? } ?>	

</fieldset>

