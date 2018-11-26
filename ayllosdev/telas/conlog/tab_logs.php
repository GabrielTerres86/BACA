<? 
/*!
 * FONTE        : tab_logs.php
 * CRIAÇÃO      : Thaise Medeiros - Envolti
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Tabela que apresenta o resultado da busca de logs.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>

<div style="display:block">
	<fieldset id="fsetLogs" name="fsetLogs">
	<legend class="txtBrancoBold" style="background-image: url(<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif); width: 100%; padding: 4px 0;"> Logs</legend>
		<div class="divRegistros">
			<table class="">
			<thead>
				<tr>
					<th></th>
					<th><? echo utf8ToHtml('Cooper'); ?></th>
					<th><? echo utf8ToHtml('Idprglog');  ?></th>
					<th><? echo utf8ToHtml('Programa');  ?></th>
					<th><? echo utf8ToHtml('Arquivo Log');  ?></th>
					<th><? echo utf8ToHtml('Dh Início');  ?></th>
					<th><? echo utf8ToHtml('Dh Fim');  ?></th>
					<th><? echo utf8ToHtml('Tipo Execução');  ?></th>
				</tr>
			</thead>
			<tbody><?
				if ( count($logs) == 0) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="8" style="width: 80px; text-align: center !important;">
								<b>N&atilde;o h&aacute; registros para exibir.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibi-los em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($logs); $i++) { ?>
						<tr>
							<td>
								<span><? echo $i +1; ?></span>
									  <? echo $i +1; ?>
							</td>
							<td style="text-align: right">
								<span><? echo getByTagName($logs[$i]->tags,'Cooper'); ?></span>
									  <? echo getByTagName($logs[$i]->tags,'Cooper'); ?>
							</td>
							<td id="idprglog" value="<? echo getByTagName($logs[$i]->tags,'Idprglog'); ?>">
								<span><? echo getByTagName($logs[$i]->tags,'Idprglog'); ?></span>
									  <? echo getByTagName($logs[$i]->tags,'Idprglog'); ?>
							</td>
							<td>
								<span><? echo getByTagName($logs[$i]->tags,'Programa'); ?></span>
									  <? echo getByTagName($logs[$i]->tags,'Programa'); ?>
							</td>
							<td>
								<span><? echo getByTagName($logs[$i]->tags,'ArquivoLog'); ?></span>
								<? echo getByTagName($logs[$i]->tags,'ArquivoLog'); ?>
							</td>
							<td>
								<span><? echo getByTagName($logs[$i]->tags,'DhInicio'); ?></span>
									  <? echo getByTagName($logs[$i]->tags,'DhInicio'); ?>
							</td>
							<td>
								<span><? echo getByTagName($logs[$i]->tags,'DhFim'); ?></span>
									  <? echo getByTagName($logs[$i]->tags,'DhFim'); ?>
							</td>
							<td style="text-align: right">
								<span><? echo getByTagName($logs[$i]->tags,'TpExecuc'); ?></span>
									  <? echo getByTagName($logs[$i]->tags,'TpExecuc'); ?>
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