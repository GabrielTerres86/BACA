<? 
/*!
 * FONTE        : tabela_referencias.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 28/04/2010 
 * OBJETIVO     : Tabela que apresenda as REFERÊNCIAS
 *
 * ALTERACOES   : 05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */	
?>

<div class="divRegistros">
	<table>
		<thead>
			<tr><th>Conta/dv</th>
				<th>Nome</th>
				<th>Telefone</th>
				<th>E-mail</th></tr>			
		</thead>		
		<tbody>
			<? foreach( $registros as $registro ) {?>
				<tr><td><span><? echo getByTagName($registro->tags,'nrdctato') ?></span>
						<? echo getByTagName($registro->tags,'cddctato') ?>
				        <input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($registro->tags,'nrdrowid') ?>" /></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'nmdavali'),21,'maiuscula')   ?></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'nrtelefo'),18,'minuscula') ?></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'dsdemail'),33,'minuscula') ?></td></tr>				
			<? } ?>			
		</tbody>
	</table>
</div>

<div id="divBotoes">
	
	<? if ($flgcadas == 'M' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
	<? } ?>
	
	<input type="image" id="btAlterar"   src="<? echo $UrlImagens; ?>botoes/alterar.gif"   onClick="controlaOperacao('CA');" />
	<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacao('CC');" />
	<input type="image" id="btExcluir"   src="<? echo $UrlImagens; ?>botoes/excluir.gif"   onClick="controlaOperacao('TE');" />
	<input type="image" id="btIncluir"   src="<? echo $UrlImagens; ?>botoes/incluir.gif"   onClick="controlaOperacao('CI');" />
	<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />
	
	
</div>