<? 
/*!
 * FONTE        : tab_regional.php				Última alteração: 27/11/2015
 * CRIAÇÃO      : Jéssica - DB1	
 * DATA CRIAÇÃO : 18/09/2015
 * OBJETIVO     : Tabela de Regionais
 * --------------
 * ALTERAÇÕES   :  27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                               (Adriano). 
 * --------------
 */	
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
 
?>

<form id="frmTabelaRegionais" name="frmTabelaRegionais" class="formulario">

	<fieldset id="fsetTabelaRegionais" name="fsetTabelaRegionais" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Regional</legend>	
			
		<div id="tabRegional" style="display:block">
			<div class="divRegistros">
				<table class="tituloRegistros">
					<thead>
						<tr>
							<th><? echo utf8ToHtml('Regional');  ?></th>
							<th><? echo utf8ToHtml('Responsavel');  ?></th>
							<th><? echo utf8ToHtml('E-mail');   ?></th>				
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
										<b>N&atilde;o h&aacute; registros de Regionais cadastrados.</b>
									</td>
								</tr>							
						<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
						} else {
							for ($i = 0; $i < count($registros); $i++) {
							?>
								<tr>
									<td><input type="hidden" id="conteudo" name="conteudo" value="<? echo 1; ?>" />
										<input type="hidden" id="cddsregi" name="cddsregi" value="<? echo getByTagName($registros[$i]->tags,'cddsregi') ?>" />
										<input type="hidden" id="dsoperad" name="dsoperad" value="<? echo getByTagName($registros[$i]->tags,'dsoperad') ?>" />
										<input type="hidden" id="dsdemail" name="dsdemail" value="<? echo getByTagName($registros[$i]->tags,'dsdemail') ?>" />
										<input type="hidden" id="dsdregio" name="dsdregio" value="<? echo getByTagName($registros[$i]->tags,'dsdregio') ?>" />
										<input type="hidden" id="cddregio" name="cddregio" value="<? echo getByTagName($registros[$i]->tags,'cddregio') ?>" />
										<input type="hidden" id="cdoperad" name="cdoperad" value="<? echo getByTagName($registros[$i]->tags,'cdopereg') ?>" />
										<input type="hidden" id="nmoperad" name="nmoperad" value="<? echo getByTagName($registros[$i]->tags,'nmoperad') ?>" />
										
										<span><? echo getByTagName($registros[$i]->tags,'cddsregi'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'cddsregi'); ?>
									</td>
									<td><span><? echo getByTagName($registros[$i]->tags,'dsoperad'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'dsoperad'); ?>
									</td>													
									<td><span><? echo getByTagName($registros[$i]->tags,'dsdemail'); ?></span>
											  <? echo getByTagName($registros[$i]->tags,'dsdemail'); ?>
									</td>
																																																	
								</tr>
							<? } ?>
					<? } ?>
					
					</tbody>
				</table>
			</div>
			<div id="divRegistrosRodape" class="divRegistrosRodape">
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
	$('#divRegistrosRodape','#divTela').formataRodapePesquisa();
</script>
