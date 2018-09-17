<? 
/*!
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 21/12/2011 
 * OBJETIVO     : Tabela que apresenta os contrato
 * --------------
 * ALTERAÇÕES   : 21/11/2012 - Alterado botões do tipo campo <input> por
 *				  campo <a> (Daniel).
				 
				  30/12/2014 - Padronizando a mascara do campo nrctremp.
					  		   10 Digitos - Campos usados apenas para visualização
					 		   8 Digitos - Campos usados para alterar ou incluir novos contratos
					 		   (Kelvin - SD 233714)
 * --------------
 */	
?>

<div id="divContrato">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Contrato'); ?></th>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Emprestado');  ?></th>
					<th><? echo utf8ToHtml('Parcelas');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
					<th><? echo utf8ToHtml('LC');  ?></th>
					<th><? echo utf8ToHtml('Fin');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrctremp') ?></span>
							      <? echo mascara(getByTagName($r->tags,'nrctremp'),'#.###.###.###') ?>
								  <input type="hidden" id="nrctremp" name="nrctremp" value="<? echo mascara(getByTagName($r->tags,'nrctremp'),'#.###.###.###') ?>" />								  
								  
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt') ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vlemprst'),'MOEDA') ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlemprst')) ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'qtpreemp') ?></span>
							      <? echo getByTagName($r->tags,'qtpreemp') ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vlpreemp'),'MOEDA') ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlpreemp')) ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdlcremp') ?></span>
							      <? echo getByTagName($r->tags,'cdlcremp') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdfinemp') ?></span>
							      <? echo getByTagName($r->tags,'cdfinemp') ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); cNrctremp.focus(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaContrato(); return false;">Continuar</a>
</div>