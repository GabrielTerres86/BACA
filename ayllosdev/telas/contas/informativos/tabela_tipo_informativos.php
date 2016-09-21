<?php
/*!
 * FONTE        : tabela_informativos.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/042010 
 * OBJETIVO     : Tabela que apresenda os INFORMATIVOS do titular selecionado
 * ALTERACOES : 14/07/2016 - Correcao do titulo da coluna que estava sendo tratado como uma constante.SD 479874 (Carlos Rafael Tanholi).
 */	
?>
<div class="divRegistros">
	<table>
		<thead>
			<tr>
				<th>Informativo</th>
				<th>Forma Envio</th>
				<th>Per&iacute;odo</th>
				<th>Sugerido</th>
			</tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $registro ) {?>
				<tr><td><span><? echo getByTagName($registro->tags,'nmrelato') ?></span>
						<? echo getByTagName($registro->tags,'nmrelato') ?>
						<input type="hidden" id="cdrelato" name="cdrelato" value="<? echo getByTagName($registro->tags,'cdrelato') ?>" />					
						<input type="hidden" id="cdprogra" name="cdprogra" value="<? echo getByTagName($registro->tags,'cdprogra') ?>" />					
						<input type="hidden" id="cddfrenv" name="cddfrenv" value="<? echo getByTagName($registro->tags,'cddfrenv') ?>" />					
						<input type="hidden" id="cdperiod" name="cdperiod" value="<? echo getByTagName($registro->tags,'cdperiod') ?>" /></td>					
					<td><? echo getByTagName($registro->tags,'dsdfrenv') ?></td>
					<td><? echo getByTagName($registro->tags,'dsperiod'); ?></td>
					<td><span><? echo getByTagName($registro->tags,'envcobrg'); ?></span>
					<? echo utf8ToHtml( stringTabela( ( getByTagName($registro->tags,'envcobrg') == 'no') ? 'NÃO' : 'sim' ,22,'maiuscula') )?></td>
				</tr>				
			<? } ?>			
		</tbody>
	</table>
</div> 
<div id="divBotoes">
	<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="controlaOperacao('');" />
	<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('CI');" />		
</div>
