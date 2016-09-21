<? 
/*!
 * FONTE        : tab_bndes.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : 24/05/2013 
 * OBJETIVO     : Tabela com as pretações de bndes da conta selecionada
 * --------------
 * ALTERAÇÕES   : 06/01/2015 - Padronizando a mascara do campo nrctremp.
 *	   	                       10 Digitos - Campos usados apenas para visualização
 *			                   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *				               (Kelvin - SD 233714)
 *				  
 *				  30/06/2016 - Ajuste feito na tela pois a busca da descrição do produto
 *							   estava com o sintaxe errado, isso para corrigir o problema
 *							   do chamado 475692. (Kelvin)
 *
 * --------------
 */	
 ?>
 
<div class="divRegistros">
	<table id="tituloRegistros" class="tituloRegistros">
		<thead>
		<tr><th><? echo utf8ToHtml('Produto'); ?></th>
			<th><? echo utf8ToHtml('Contrato'); ?></th>
			<th><? echo utf8ToHtml('Emprestado'); ?></th>
		</tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $banco ) {  $conta++; ?>
				
				<tr>
						<input type="hidden" id="conta" name="conta" value="<? echo $conta ?>" />
						<input type="hidden" id="vlparepr" name="vlparepr" value="<? echo getByTagName($banco->tags,'vlparepr') ?>" />
						<input type="hidden" id="vlsdeved" name="vlsdeved" value="<? echo getByTagName($banco->tags,'vlsdeved') ?>" />
						<input type="hidden" id="qtdmesca" name="qtdmesca" value="<? echo getByTagName($banco->tags,'qtdmesca') ?>" />
						<input type="hidden" id="perparce" name="perparce" value="<? echo getByTagName($banco->tags,'perparce') ?>" />
						<input type="hidden" id="dtinictr" name="dtinictr" value="<? echo getByTagName($banco->tags,'dtinictr') ?>" />
						<input type="hidden" id="dtlibera" name="dtlibera" value="<? echo getByTagName($banco->tags,'dtlibera') ?>" />
						<input type="hidden" id="qtparctr" name="qtparctr" value="<? echo getByTagName($banco->tags,'qtparctr') ?>" />
						<input type="hidden" id="dtpripag" name="dtpripag" value="<? echo getByTagName($banco->tags,'dtpripag') ?>" />
						<input type="hidden" id="dtpricar" name="dtpricar" value="<? echo getByTagName($banco->tags,'dtpricar') ?>" />
						<input type="hidden" id="percaren" name="percaren" value="<? echo getByTagName($banco->tags,'percaren') ?>" />
				
					<td id="dsdprodu" align="left" ><? echo getByTagName($banco->tags,'dsdprodu') ?>
						<input type="hidden" id="dsdprodu" name="dsdprodu" value="<? echo getByTagName($banco->tags,'dsdprodu') ?>" />
					</td>
					<td id="nrctremp" align="right" ><? echo formataNumericos("zz.zzz.zzz",getByTagName($banco->tags,'nrctremp'),"."); ?>
						<input type="hidden" id="tbnrctremp" name="tbnrctremp" value="<? echo getByTagName($banco->tags,'nrctremp') ?>" />
					</td>
											
					<td id="vlropepr" align="right" ><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlropepr')),2,",",".");  ?>
						<input type="hidden" id="vlropepr" name="vlropepr" value="<? echo getByTagName($banco->tags,'vlropepr') ?>" />
					</td>
				</tr>	
					<script>
						criaObjetoBndes('<? echo getByTagName($banco->tags,'dsdprodu') ?>', 
										'<? echo getByTagName($banco->tags,'nrctremp') ?>',
										'<? echo getByTagName($banco->tags,'vlropepr') ?>',
										'<? echo getByTagName($banco->tags,'vlparepr') ?>',
										'<? echo getByTagName($banco->tags,'vlsdeved') ?>', 
										'<? echo getByTagName($banco->tags,'qtdmesca') ?>', 
										'<? echo getByTagName($banco->tags,'perparce') ?>',
										'<? echo getByTagName($banco->tags,'dtinictr') ?>',
										'<? echo getByTagName($banco->tags,'dtlibera') ?>',
										'<? echo getByTagName($banco->tags,'qtparctr') ?>',
										'<? echo getByTagName($banco->tags,'dtpripag') ?>',
										'<? echo getByTagName($banco->tags,'dtpricar') ?>',
										'<? echo getByTagName($banco->tags,'percaren') ?>');
					</script>
			<? } ?>			
		</tbody>		
	</table>
</div>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina('true');" />
	<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="btConsultar();" />
</div>
