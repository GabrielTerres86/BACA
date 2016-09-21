<? 
/*!
 * FONTE        : tab_tipo2.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 29/09/2011 
 * OBJETIVO     : Tabela que apresenta os contrato
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 *
 *				  12/12/2014 - Adicionado coluna de Valor na tabAplicacao. (Reinert)
 * --------------
 */	
?>

<div id="tabAplicacao">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th></th>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Historico');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
					<th><? echo utf8ToHtml('Docmto');  ?></th>
					<th><? echo utf8ToHtml('Dt Vencto');  ?></th>
					<th><? echo utf8ToHtml('Saldo');  ?></th>
					<th><? echo utf8ToHtml('Saldo Resg');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				
				foreach( $aplicacao as $r ) { 
					$a['tpaplica'] = getByTagName($r->tags,'tpaplica');
					$a['nraplica'] = getByTagName($r->tags,'nraplica');
					$a['tpproapl'] = getByTagName($r->tags,'tpproapl');
				?>
					<tr>
						<td><input name="aplicacao" type="checkbox" value="<? echo getByTagName($r->tags,'tpaplica') ?>-<? echo getByTagName($r->tags,'nraplica') ?>-<? echo getByTagName($r->tags,'tpproapl') ?>" <? echo in_array($a, $rgaplica) ? 'checked' : 'teste' ?> ></td>
						<td><span><? echo getByTagName($r->tags,'dtmvtolt') ?></span>
								  <? echo getByTagName($r->tags,'dtmvtolt') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dshistor') ?></span>
								  <? echo getByTagName($r->tags,'dshistor') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlaplica') ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'vlaplica')) ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdocmto') ?></span>
								  <? echo getByTagName($r->tags,'nrdocmto') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dtvencto') ?></span>
								  <? echo getByTagName($r->tags,'dtvencto') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlsldapl') ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'vlsldapl')) ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'sldresga') ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'sldresga')) ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>
	

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico')); bloqueiaFundo( $('#divRotina') ); return false;">Cancelar</a>
	<a href="#" class="botao" id="btSalvar" onClick="continuarAplicacao('<? echo $tpaplica ?>'); return false;">Continuar</a>
</div>