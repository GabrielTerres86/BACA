<? 
/*!
 * FONTE        : tab_log_detalhes.php
 * CRIAÇÃO      : Thaise Medeiros - Envolti
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Tabela que apresenta o resultado da busca de detalhes do log.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>

<div style="display:block">
	<fieldset id="fsetDetalhes" name="fsetDetalhes">
	<legend class="txtBrancoBold" style="background-image: url(<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif); width: 100%; padding: 4px 0;">Detalhes</legend>
		<div class="divRegistros">
			<table class="" style="table-layout: fixed;">
			<thead>
				<tr>
					<th></th>
					<th><? echo utf8ToHtml('Id Ocorrência'); ?></th>
					<th><? echo utf8ToHtml('Dh Ocorrência');  ?></th>
					<th><? echo utf8ToHtml('Tp Ocorren');  ?></th>
					<th><? echo utf8ToHtml('Criticid');  ?></th>
					<th><? echo utf8ToHtml('Cod. Mensagem');  ?></th>
					<th><? echo utf8ToHtml('Descrição');  ?></th>
				</tr>
			</thead>
			<tbody><?
				if ( count($detalhes) == 0) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="7" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros para exibir.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibi-los em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($detalhes); $i++) { ?>
						<tr id="linObsClick_<? echo $i; ?>">
							<td>
								<span><? echo $i +1; ?></span>
									  <? echo $i +1; ?>
							</td>
							<td style="text-align: right">
								<span><? echo getByTagName($detalhes[$i]->tags,'IdOcorrencia'); ?></span>
									  <? echo getByTagName($detalhes[$i]->tags,'IdOcorrencia'); ?>
							</td>
							<td>
								<span><? echo getByTagName($detalhes[$i]->tags,'DhOcorrencia'); ?></span>
									  <? echo getByTagName($detalhes[$i]->tags,'DhOcorrencia'); ?>
							</td>
							<td>
								<span><? echo getByTagName($detalhes[$i]->tags,'TipoOcorrencia'); ?></span>
									  <? echo getByTagName($detalhes[$i]->tags,'TipoOcorrencia'); ?>
							</td>
							<td>
								<span><? echo getByTagName($detalhes[$i]->tags,'Criticidade'); ?></span>
									  <? echo getByTagName($detalhes[$i]->tags,'Criticidade'); ?>
							</td>
							<td>
								<span><? echo getByTagName($detalhes[$i]->tags,'Cdmensagem'); ?></span>
									  <? echo getByTagName($detalhes[$i]->tags,'Cdmensagem'); ?>
							</td>
							<td style="-ms-word-wrap: break-word">
									  <? echo getByTagName($detalhes[$i]->tags,'Descricao'); ?>
								<span><? echo getByTagName($detalhes[$i]->tags,'Descricao'); ?></span>
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