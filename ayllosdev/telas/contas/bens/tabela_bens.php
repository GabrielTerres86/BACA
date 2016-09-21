<? 
/*!
 * FONTE        : tabela_bens.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 03/03/2010 
 * OBJETIVO     : Tabela que apresenda os bens do titular selecionado
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [05/05/2010] Rodolpho Telmo (DB1) : Adaptação da tela ao "tableSorter" 
 * 002: [04/08/2015] Gabriel (RKAM)       : Reformulacao cadastral.
 */	
?>

<div class="divRegistros">
	<table>
		<thead>
			<tr><th>Descri&ccedil;&atilde;o do Bem</th>
				<th>% sem &Ocirc;nus </th>
				<th>Nr. Parc.</th>
				<th>Vl. Parcela</th>
				<th>Vl. Bem</th></tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $bem ) { ?>
				<?;?>
				<tr><td><span><? echo stringTabela(getByTagName($bem->tags,'dsrelbem'),31,'maiuscula') ?></span>
						<? echo stringTabela(getByTagName($bem->tags,'dsrelbem'),31,'maiuscula') ?>
						<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($bem->tags,'nrdrowid') ?>" />
						<input type="hidden" id="idseqbem" name="idseqbem" value="<? echo getByTagName($bem->tags,'idseqbem') ?>" /></td>
					<td><span><? echo str_replace(',','.',getByTagName($bem->tags,'persemon')) ?></span>
						<? echo number_format(str_replace(',','.',getByTagName($bem->tags,'persemon')),2,',','.') ?></td>
					<td><? echo getByTagName($bem->tags,'qtprebem') ?></td>
					<td><span><? echo str_replace(',','.',getByTagName($bem->tags,'vlprebem')) ?></span>
						<? echo number_format(str_replace(',','.',getByTagName($bem->tags,'vlprebem')),2,',','.') ?></td>
					<td><span><? echo str_replace(',','.',getByTagName($bem->tags,'vlrdobem')) ?></span>
						<? echo number_format(str_replace(',','.',getByTagName($bem->tags,'vlrdobem')),2,',','.') ?></td></tr>				
			<? } ?>			
		</tbody>
	</table>
</div> 

<div id="divBotoes">
	<?if ( $operacao != 'SC' ) { ?>
	
		<? if ($flgcadas == 'M') { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();"   />
		<? } else { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);"   />
		<? } ?>
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('CA');" />
		<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('CX');" />
		<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('CI');" />	
		<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />	
	
	<?} else {?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);"   />
		<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacao('CF');" />
	<?}?>
</div>