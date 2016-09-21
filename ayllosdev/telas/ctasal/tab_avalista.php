<? 
/*!
 * FONTE        : tab_avalista.php
 * CRIAÇÃO      : Gabriel Capoia - (DB1)
 * DATA CRIAÇÃO : 21/01/2013 
 * OBJETIVO     : Tabela que apresenta os avalistas
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<div id="divContrato">
	<div class="divRegistros">	
		<table>
			<thead style="display:block;">
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
						<td><? echo getByTagName($r->tags,'nmfuncio') ?></td>						
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