<? 
/*!
 * FONTE        : tab_conta_emp.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 17/07/2015
 * OBJETIVO     : Tela de Pesquisa de Associados
 */	 
?>
<div id="divContaEmp">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta/dv'); ?></th>
					<th><? echo utf8ToHtml('Nome do Associado');  ?></th>					
				</tr>
			</thead>
			<tbody>			
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrdconta') ?></span>
							<? echo mascara(getByTagName($r->tags,'nrdconta'),'####.###.#') ?>
							<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($r->tags,'nrdconta') ?>" /></td>
							<input type="hidden" id="nmfuncio" name="nmfuncio" value="<? echo getByTagName($r->tags,'nmpesttl') ?>" /></td>
						<td><span><? echo getByTagName($r->tags,'nmpesttl') ?></span>
						          <? echo getByTagName($r->tags,'nmpesttl') ?></td>
					</tr>
				<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); cNrdconta.focus(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaAvalista(); return false;">Continuar</a>
</div>