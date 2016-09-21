<? 
/*!
 * FONTE        : tab_historico.php									Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 18/10/2015
 * OBJETIVO     : Tabela de inclusão de historicos
 * --------------
 * ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1
							  (Adriano).
 * --------------
 */	
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
 
 
?>
<form id="frmHistorico" name="frmHistorico" class="formulario" style="display:block;">

	<fieldset id="fsetHistorico" name="fsetHistorico" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Hist&oacute;ricos</legend>		
				
		<div id="tabHistorico" style="display:block">
			<div class="divRegistros">
				<table class="tituloRegistros">
					<thead>
						<tr>
							<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>
							<th><? echo utf8ToHtml('Descri&ccedil;&atilde;o');  ?></th>
							<th><? echo utf8ToHtml('Tipo');   ?></th>									
						</tr>
					</thead>
					<tbody>
						<?
						if ( count($registros) == 0 ) {
							$i = 0;
							// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
							?> <tr>
									<td colspan="6" style="width: 80px; text-align: center;">
										<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
										<b>ATENCAO!!! Itens da tabela CONTAS3026 nao foram cadastrados.</b>
									</td>
								</tr>							
						<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
						} else {
							for ($i = 0; $i < count($registros); $i++) {
							?>
								<tr>
									<td><input type="hidden" id="conteudo" name="conteudo" value="<? echo 1; ?>" />
										<input type="hidden" id="cdhistor" name="cdhistor" value="<? echo getByTagName($registros[$i]->tags,'cdhistor') ?>" />
										<input type="hidden" id="dshistor" name="dshistor" value="<? echo getByTagName($registros[$i]->tags,'dshistor') ?>" />
										<input type="hidden" id="dstphist" name="dstphist" value="<? echo getByTagName($registros[$i]->tags,'dstphist') ?>" />
									
										<span><? echo getByTagName($registros[$i]->tags,'cdhistor'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'cdhistor'); ?>
									</td>
									<td><span><? echo getByTagName($registros[$i]->tags,'dshistor'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'dshistor'); ?>
									</td>
									<td><span><? echo getByTagName($registros[$i]->tags,'dstphist'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'dstphist'); ?>
									</td>
									
								</tr>
							<? } ?>
					<? } ?>
							
					
					</tbody>
				</table>
			</div>
			<div id="divPesquisaRodape" class="divPesquisaRodape">
				<table>
					<tr>
						<td>
							<?
								if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
								if ($nriniseq > 1) {
									?> <a class='paginacaoAnt'><<< Anterior</a> <?
								} else {
									?> &nbsp; <?
								}
							?>
						</td>
						<td>
							<?
								if ($nriniseq) {
									?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
							<?  } ?>
						</td>
						<td>
							<?
								if ($qtregist > ($nriniseq + $nrregist - 1)) {
									?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
								} else {
									?> &nbsp; <?
								}
							?>
						</td>
					</tr>
				</table>
						
			</div>
		</div>
		
	</fieldset>
	
</form>
<script type="text/javascript">
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>
