<? 
/*!
 * FONTE        : tab_historico.php						Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 09/10/2015
 * OBJETIVO     : Tabela de Historicos scr
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
		
		<legend>Informa&ccedil;&otilde;es</legend>
		
		<div id="tabHistorico" style="display:block">
			<div class="divRegistros">
				<table class="tituloRegistros">
					<thead>
						<tr>
							<th><? echo utf8ToHtml('Dt.Solici.');  ?></th>
							<th><? echo utf8ToHtml('Conta/dv');  ?></th>
							<th><? echo utf8ToHtml('Dt.Refere.');   ?></th>
							<th><? echo utf8ToHtml('Hist');  ?></th>					
							<th><? echo utf8ToHtml('Tipo');  ?></th>					
							<th><? echo utf8ToHtml('Valor');  ?></th>					
							<th><? echo utf8ToHtml('Dt.Envio');  ?></th>					
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
										<b>N&atilde;o h&aacute; registros de hist&oacute;ricos cadastrados.</b>
									</td>
								</tr>							
						<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
						} else {
							for ($i = 0; $i < count($registros); $i++) {
							?>
								<tr>
									<td><input type="hidden" id="conteudo" name="conteudo" value="<? echo 1; ?>" />
										<input type="hidden" id="dtsolici" name="dtsolici" value="<? echo getByTagName($registros[$i]->tags,'dtsolici') ?>" />
										<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($registros[$i]->tags,'nrdconta') ?>" />
										<input type="hidden" id="dtrefere" name="dtrefere" value="<? echo getByTagName($registros[$i]->tags,'dtrefere') ?>" />
										<input type="hidden" id="cdhistor" name="cdhistor" value="<? echo getByTagName($registros[$i]->tags,'cdhistor') ?>" />
										<input type="hidden" id="dstphist" name="dstphist" value="<? echo getByTagName($registros[$i]->tags,'dstphist') ?>" />
										<input type="hidden" id="vllanmto" name="vllanmto" value="<? echo getByTagName($registros[$i]->tags,'vllanmto') ?>" />
										<input type="hidden" id="dttransm" name="dttransm" value="<? echo getByTagName($registros[$i]->tags,'dttransm') ?>" />
										<span><? echo getByTagName($registros[$i]->tags,'dtsolici'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'dtsolici'); ?>
									</td>
									<td><span><? echo getByTagName($registros[$i]->tags,'nrdconta'); ?></span>
											  <? echo mascara(getByTagName($registros[$i]->tags,'nrdconta'),'####.###.#'); ?>
									</td>													
																
									<td><span><? echo getByTagName($registros[$i]->tags,'dtrefere'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'dtrefere'); ?>
									</td>
																																										
															
									<td><span><? echo getByTagName($registros[$i]->tags,'cdhistor'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'cdhistor'); ?>
									</td>
									
									<td><span><? echo getByTagName($registros[$i]->tags,'dstphist'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'dstphist'); ?>
									</td>
																														
									<td><span><? echo number_format(str_replace(",","",getByTagName($registros[$i]->tags,'vllanmto')),4,",","."); ?></span>
											  <? echo number_format(str_replace(",","",getByTagName($registros[$i]->tags,'vllanmto')),2,",","."); ?>
									</td>
									
									
									<td><span><? echo getByTagName($registros[$i]->tags,'dttransm'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'dttransm'); ?>
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
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscaDados(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscaDados(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divPesquisaRodape','#tabHistorico').formataRodapePesquisa();
		
	$('#btVoltar','#divBotoes').focus();
	
</script>
