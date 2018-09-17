<? 
/*!
 * FONTE        : tabela_garseg.php
 * CRIAÇÃO      : Rogério Giacomini (GATI)
 * DATA CRIAÇÃO : setembro/2011
 * OBJETIVO     : Tabela que apresenta as parcelas de garantias
 * --------------
 * ALTERAÇÕES   : 
 * 001: 18/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */
?>
<div class="divRegistros">
	<table>
		<thead>
			<tr>
				<th>Garantia</th>
				<th>Valor</th>
				<th>Franquia</th>
			</tr>
		</thead>
		<tbody>
		<!--<form id="formCheckParcelas" name="formCheckParcelas">-->
			<?
				foreach( $registros as $registro ) {
					if($registro->tags[0]->cdata){
						?>
						<tr>
							<td>
								<input type="hidden" id="nrseqinc" name="nrseqinc" value="<? echo getByTagName($registro->tags,'nrseqinc') ?>"/>
								<input type="hidden" id="dsgarant" name="dsgarant" value="<? echo getByTagName($registro->tags,'dsgarant') ?>"/>
								<? echo getByTagName($registro->tags,'dsgarant') ?>
							</td>
							<td>
								<input type="hidden" id="vlgarant" name="vlgarant" value="<? echo getByTagName($registro->tags,'vlgarant') ?>"/>
								<? echo number_format(str_replace(",",".",getByTagName($registro->tags,'vlgarant')),2,",","."); ?>
							</td>
							<td>
								<input type="hidden" id="dsfranqu" name="dsfranqu" value="<? echo getByTagName($registro->tags,'dsfranqu') ?>"/>
								<? echo getByTagName($registro->tags,'dsfranqu') ?>
							</td>
						</tr>
						<?
					}
				}
			?>
		<!--</form>-->
		</tbody>		
	</table>	
</div>
<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btIncluir"   onclick="controlaOperacao('INCLUIR');">Incluir</a>
	<a href="#" class="botao" id="btAlterar"   onclick="controlaOperacao('ALTERAR');">Alterar</a>
	<a href="#" class="botao" id="btDeletar"   onclick="controlaOperacao('EXCLUIR');">Excluir</a>
</div>