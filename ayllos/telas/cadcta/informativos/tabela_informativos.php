<? 
/*!
 * FONTE        : tabela_informativos.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/042010 
 * OBJETIVO     : Tabela que apresenda os INFORMATIVOS do titular selecionado
 *
 * ALTERACOES   : 18/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */	
?>
<div class="divRegistros divRegistrosInformativos">
	<table>
		<thead>
			<tr>
				<th>Informativo</th>
				<th>Forma Envio</th>
				<th><? echo utf8ToHtml('Período');?></th>
				<th>Recebimento</th>
			</tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $registro ) {?>
				<tr><td><span><? echo getByTagName($registro->tags,'nmrelato') ?></span>
						<? echo getByTagName($registro->tags,'nmrelato') ?>
						<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($registro->tags,'nrdrowid') ?>" /></td>					
					<td><? echo getByTagName($registro->tags,'dsdfrenv') ?></td>
					<td><? echo getByTagName($registro->tags,'dsperiod'); ?></td>
					<td><span><? echo getByTagName($registro->tags,'dsrecebe'); ?></span>
					<? echo stringTabela(getByTagName($registro->tags,'dsrecebe'),22,'minuscula')?></td>
				</tr>				
			<? } ?>			
		</tbody>
	</table>
</div> 
<div id="divBotoes">
	<? if ($flgcadas == 'M') { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
	<? } ?>
	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('CA');" />
	<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('CX');" />
	<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('BI');" />	
	<!--<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />-->
</div>
