<? 
/*!
 * FONTE        : tab_poupanca.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 03/02/2012 
 * OBJETIVO     : Tabela que apresenta as poupancas
 * --------------
 * ALTERAÇÕES   : 29/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout (Daniel).
 * --------------
 */	
?>

<div id="divPoupanca">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data Movto'); ?></th>
					<th><? echo utf8ToHtml('Apli Programada');  ?></th>
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
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); cNraplica.focus(); return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaPoupanca();  return false;" >Continuar</a>
</div>