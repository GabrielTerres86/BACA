<? 
/*!
 * FONTE        : tab_registros.php						Última alteração:  06/06/2017
 * CRIAÇÃO      : Andrei - RKAM
 * DATA CRIAÇÃO : Maio/2016
 * OBJETIVO     : Tabela que apresenta os detalhes do rating
 * --------------
 * ALTERAÇÕES   :  06/06/2017 - Corrigido a ordenação da tebela. (Andrey Formigari - Mouts)
                    
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmDetalhes" name="frmDetalhes" class="formulario" style="display:none;">

	<fieldset id="fsetRatings" name="fsetRatings" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Ratings"; ?></legend>
		
		<div class="divRegistros">
		
			<table>
				<thead>
					<tr>
						<th>PA</th>
						<th>Conta/dv</th>
						<th>Valor</th>
						<th>Tipo</th>
						<th>Contrato</th>
						<th>Data</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $result ) {    ?>
						<tr onclick="selecionaRating(this);">	
							<td><span><? echo getByTagName($result->tags,'cdagenci'); ?></span> <? echo getByTagName($result->tags,'cdagenci'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nrdconta'); ?></span> <? echo getByTagName($result->tags,'nrdconta'); ?> </td>
							<td><span><? echo str_replace(",",".",getByTagName($result->tags,'vloperac')); ?></span><? echo number_format(str_replace(",",".",getByTagName($result->tags,'vloperac')),2,",","."); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dsdopera'); ?></span> <? echo getByTagName($result->tags,'dsdopera'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nrctrrat'); ?></span><? echo getByTagName($result->tags,'nrctrrat'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dtmvtolt'); ?></span><? echo getByTagName($result->tags,'dtmvtolt'); ?> </td>
							<input type="hidden" id="inrisctl" name="inrisctl" value="<? echo getByTagName($result->tags,'inrisctl'); ?>" />
							<input type="hidden" id="nrnotatl" name="nrnotatl" value="<? echo getByTagName($result->tags,'nrnotatl'); ?>" />
							<input type="hidden" id="indrisco" name="indrisco" value="<? echo getByTagName($result->tags,'indrisco'); ?>" />
							<input type="hidden" id="nrnotrat" name="nrnotrat" value="<? echo getByTagName($result->tags,'nrnotrat'); ?>" />
							<input type="hidden" id="dteftrat" name="dteftrat" value="<? echo getByTagName($result->tags,'dteftrat'); ?>" />
							<input type="hidden" id="nmoperad" name="nmoperad" value="<? echo getByTagName($result->tags,'nmoperad'); ?>" />
							<input type="hidden" id="vlutlrat" name="vlutlrat" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlutlrat')),2,",",".");  ?>" />
							<input type="hidden" id="nrctrrat" name="nrctrrat" value="<? echo getByTagName($result->tags,'nrctrrat'); ?>" />
							<input type="hidden" id="tpctrrat" name="tpctrrat" value="<? echo getByTagName($result->tags,'tpctrrat'); ?>" />
							<input type="hidden" id="insitrat" name="insitrat" value="<? echo getByTagName($result->tags,'insitrat'); ?>" />
							<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($result->tags,'nrdconta'); ?>" />
							<input type="hidden" id="dsdopera" name="dsdopera" value="<? echo getByTagName($result->tags,'dsdopera'); ?>" />
							
						</tr>	
					<? } ?>
				</tbody>	
			</table>
		</div>
		<div id="divRegistrosRodape" class="divRegistrosRodape">
			<table>	
				<tr>
					<td>
						<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
						<? if ($nriniseq > 1){ ?>
							   <a class="paginacaoAnt"><<< Anterior</a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
					<td>
						<? if (isset($nriniseq)) { ?>
							   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
							<? } ?>
					</td>
					<td>
						<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
							  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
				</tr>
			</table>
		</div>	
	</fieldset>
	
	<fieldset id="fsetDetalhes" name="fsetDetalhes" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Detalhes"; ?></legend>
		
		<label for="inrisctl"><? echo utf8ToHtml('Risco Coop.:') ?></label>
		<input type="text" id="inrisctl" name="inrisctl"/>
		
		<label for="nrnotatl"><? echo utf8ToHtml('Nota:') ?></label>
		<input type="text" id="nrnotatl" name="nrnotatl"/>
		
		<label for="indrisco"><? echo utf8ToHtml('Rating:') ?></label>
		<input type="text" id="indrisco" name="indrisco"/>

		<label for="nrnotrat"><? echo utf8ToHtml('Nota:') ?></label>
		<input type="text" id="nrnotrat" name="nrnotrat"/>

		<label for="dteftrat"><? echo utf8ToHtml('Efetiva&ccedil;&atilde;o:') ?></label>
		<input type="text" id="dteftrat" name="dteftrat"/>

		<label for="nmoperad"><? echo utf8ToHtml('Operador:') ?></label>
		<input type="text" id="nmoperad" name="nmoperad"/>

		<label for="vlutlrat"><? echo utf8ToHtml('Valor Utilizado:') ?></label>
		<input type="text" id="vlutlrat" name="vlutlrat"/>
		
	</fieldset>
	
</form>

<div id="divBotoesRatings" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >
																			
	<a href="#" class="botao" id="btVoltar"   onClick="controlaVoltar('2'); return false;">Voltar</a>																																							
	<a href="#" class="botao" id="btConcluir" >Concluir</a>
	<a href="#" class="botao" id="btImprimir" style="display:none;">Gerar Relat&oacute;rio</a>
																				
																				
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscaRatings(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscaRatings(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistros','#divTabela').formataRodapePesquisa();
			
</script>