<? 
/*!
 * FONTE        : tabela_telefones.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 17/05/2010 
 * OBJETIVO     : Tabela que apresenda os telefones
 *
 * ALTERACOES   : 04/08/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 *                14/01/2016 - Melhoria 147 - Campos Situacao e Origem (Heitor - RKAM)
 *
 */	
?>

<div class="divRegistros">
	<table>
		<thead>
			<tr><th>Operadora</th>
				<th>DDD</th>
				<th>Telefone</th>
				<th>Ramal</th>
				<th><? echo utf8ToHtml('Identificação') ?></th>
				<th><? echo utf8ToHtml('Situação') ?></th>
				<th>Origem</th>
				<th>Contato</th></tr>
		</thead>
		<tbody>
			<? foreach( $registros as $registro ) {?>
				<tr><td><span><? echo getByTagName($registro->tags,'nmopetfn') ?></span>
						<? echo stringTabela(getByTagName($registro->tags,'nmopetfn'),10,'maiuscula') ?>
				        <input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($registro->tags,'nrdrowid') ?>" /></td>
					<td><? echo getByTagName($registro->tags,'nrdddtfc') ?></td>
					<td><? echo getByTagName($registro->tags,'nrtelefo') ?></td>
					<td><? echo getByTagName($registro->tags,'nrdramal') ?></td>
					<td><? echo getByTagName($registro->tags,'destptfc') ?></td>
					<td><? if (getByTagName($registro->tags,'idsittfc') == 1) { echo 'Ativo'; } else if (getByTagName($registro->tags,'idsittfc') == 2) { echo 'Inativo'; } ?></td>
					<td><? if (getByTagName($registro->tags,'idorigem') == 1) { echo 'Cooperado'; } else if (getByTagName($registro->tags,'idorigem') == 2) { echo 'Cooperativa'; } else if (getByTagName($registro->tags,'idorigem') == 3) { echo 'Terceiros'; } ?></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'nmpescto'),13,'maiuscula') ?></td></tr>
			<? } ?>			
		</tbody>
	</table>  <? if (getByTagName($registro,'tptelefo') == '1' ){ echo ' selected'; } ?>
</div>

<div id="divBotoes">
	<? if( $operacao != 'SC' ){ ?>
		
		<? if ($flgcadas == 'M') { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
		<? } else { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
		<? } ?>
		
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('TA');" />
		<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('TX');" />
		<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('TI');" />	
		<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />	
		
	<?}else{?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
		<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacao('CF');" />
	<?}?>
</div>