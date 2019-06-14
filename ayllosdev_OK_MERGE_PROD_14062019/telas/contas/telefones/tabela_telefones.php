<?php
/*!
 * FONTE        : tabela_telefones.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 17/05/2010 
 * OBJETIVO     : Tabela que apresenda os telefones
 *
 * ALTERACOES   : 04/08/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 *							 14/01/2016 - Melhoria 147 - Campos Situacao e Origem (Heitor - RKAM)
 *							 13/07/2016 - Correcao do uso da funcao getByTagName. SD 479874. Carlos R.
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
			<?php foreach( $registros as $registro ) {?>
				<tr>
					<td><span><?php echo getByTagName($registro->tags,'nmopetfn') ?></span>
						<?php echo stringTabela(getByTagName($registro->tags,'nmopetfn'),10,'maiuscula') ?>
				        <input type="hidden" id="nrdrowid" name="nrdrowid" value="<?php echo getByTagName($registro->tags,'nrdrowid') ?>" /></td>
					<td><?php echo getByTagName($registro->tags,'nrdddtfc') ?></td>
					<td><?php echo getByTagName($registro->tags,'nrtelefo') ?></td>
					<td><?php echo getByTagName($registro->tags,'nrdramal') ?></td>
					<td><?php echo getByTagName($registro->tags,'destptfc') ?></td>
					<td><?php if (getByTagName($registro->tags,'idsittfc') == 1) { echo 'Ativo'; } else if (getByTagName($registro->tags,'idsittfc') == 2) { echo 'Inativo'; } ?></td>
					<td><?php if (getByTagName($registro->tags,'idorigem') == 1) { echo 'Cooperado'; } else if (getByTagName($registro->tags,'idorigem') == 2) { echo 'Cooperativa'; } else if (getByTagName($registro->tags,'idorigem') == 3) { echo 'Terceiros'; } ?></td>
					<td><?php echo stringTabela(getByTagName($registro->tags,'nmpescto'),13,'maiuscula') ?>
					</td>
				</tr>
			<?php } ?>			
		</tbody>
	</table><?php if (getByTagName($registro->tags,'tptelefo') == '1' ){ echo ' selected'; } ?>
</div>

<div id="divBotoes">
	<?php if( $operacao != 'SC' ){ ?>
		
		<?php if ($flgcadas == 'M') { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
		<?php } else { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
		<?php } ?>
		
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('TA');" />
		<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('TX');" />
		<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('TI');" />	
		<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />	
		
	<?php }else{?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
		<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacao('CF');" />
	<?php }?>
</div>