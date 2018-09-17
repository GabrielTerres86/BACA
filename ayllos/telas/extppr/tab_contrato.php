<? 
/*!
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 29/07/2011 
 * OBJETIVO     : Tabela que apresenta os contrato
 * --------------
 * ALTERAÇÕES   : 20/09/2012 - Alterado layout de botoes voltar e continuar para novo padrao
						       (Lucas R.)
 * --------------
 */	
?>

<div id="divContrato">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data Movto'); ?></th>
					<th><? echo utf8ToHtml('Poup Programada');  ?></th>
					<th><? echo utf8ToHtml('Dia Debito');  ?></th>
					<th><? echo utf8ToHtml('Vl. Prestacao');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt') ?>
								  <input type="hidden" id="nrctrrpp" name="nrctrrpp" value="<? echo getByTagName($r->tags,'nrctrrpp') ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'nrctrrpp') ?></span>
							      <? echo mascara(getByTagName($r->tags,'nrctrrpp'),'#.###.###') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'indiadeb') ?></span>
							      <? echo getByTagName($r->tags,'indiadeb') ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vlprerpp'), 'MOEDA') ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlprerpp')) ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoes">
	<!--<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina($('#divRotina')); cNraplica.focus(); return false;" /> -->
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); cNraplica.focus(); return false;" >Voltar</a>
	<!--<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="selecionaContrato();  return false;" />-->
	<a href="#" class="botao" id="btSalvar" onClick="selecionaContrato();  return false;">Continuar</a>
</div>