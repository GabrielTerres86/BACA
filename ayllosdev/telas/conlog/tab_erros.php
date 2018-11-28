<? 
/*!
 * FONTE        : tab_erros.php
 * CRIAÇÃO      : Thaise Medeiros - Envolti
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Tabela que apresenta o resultado da busca de erros.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>

<div style="display:block">
	<fieldset id="fsetErros" name="fsetErros">
	<legend class="txtBrancoBold" style="background-image: url(<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif); width: 100%; padding: 4px 0;">Erros</legend>
		<div class="divRegistros">
			<table class="">
			<thead>
				<tr>
					<th></th>
					<th><? echo utf8ToHtml('Cooper'); ?></th>
					<th><? echo utf8ToHtml('Dh Erro');  ?></th>
					<th><? echo utf8ToHtml('SqlCode');  ?></th>
					<th><? echo utf8ToHtml('Mensagem');  ?></th>
				</tr>
			</thead>
			<tbody><?
				if ( count($erros) == 0) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="5" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros para exibir.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibi-los em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($erros); $i++) { ?>
						<tr id="linObsClick_<? echo $i; ?>">
							<td style="text-align: right">
								<span><? echo $i +1; ?></span>
									  <? echo $i +1; ?>
							</td>
							<td style="text-align: right">
								<span><? echo getByTagName($erros[$i]->tags,'Cooper'); ?></span>
									  <? echo getByTagName($erros[$i]->tags,'Cooper'); ?>
							</td>
							<td>
								<span><? echo getByTagName($erros[$i]->tags,'Data'); ?></span>
									  <? echo getByTagName($erros[$i]->tags,'Data'); ?>
							</td>
							<td>
								<span><? echo getByTagName($erros[$i]->tags,'Sqlcode'); ?></span>
									  <? echo getByTagName($erros[$i]->tags,'Sqlcode'); ?>
							</td>
							<td>
								<span><? echo getByTagName($erros[$i]->tags,'Descricao'); ?></span>
									  <? echo getByTagName($erros[$i]->tags,'Descricao'); ?>
							</td>
						</tr>
			<?  	}
				} ?>	
			</tbody>
		</table>
	</div>
	</fieldset>
</div>

<script type="text/javascript">
    
	$('#cddopcao', '#frmCab').attr('disabled', true);
    //$('#cddindexC', '#frmCab').attr('disabled', true);
</script>