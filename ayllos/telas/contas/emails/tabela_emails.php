<? 
/*!
 * FONTE        : tabela_emails.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 17/05/2010 
 * OBJETIVO     : Tabela que apresenda os EMAILS
 *
 * ALTERACOES   : 05/05/2014 - Alterado o tamanho do e-mail para 60 caracteres. (Douglas Quisinski).
 *
 *                04/08/2015 - Reformulacao cadastral (Gabriel-Rkam).
 *
 */	
?>

<div class="divRegistros">
	<table>
		<thead>
			<tr><th>E-Mail</th>
				<th>Setor</th>
				<th>Pessoa Contato</th>
		</thead>		
		<tbody>
			<? foreach( $registros as $registro ) {?>
				<tr><td><span><? echo getByTagName($registro->tags,'dsdemail') ?></span>
						<? echo stringTabela(getByTagName($registro->tags,'dsdemail'),60,'minuscula') ?>
				        <input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($registro->tags,'nrdrowid') ?>" /></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'secpscto'),10,'maiuscula') ?></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'nmpescto'),30,'maiuscula') ?></td></tr>
			<? } ?>			
		</tbody>
	</table>
</div>

<div id="divBotoes">
	<?if ( $operacao != 'SC') { ?>
		
		<? if ($flgcadas == 'M') { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
		<? } else { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
		<? } ?>
		
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('TA');" />
		<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('TE');" />
		<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('TI');" />	
		<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />	
		
	<?}else{?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
		<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacao('CF');" />
	<?}?>
</div>