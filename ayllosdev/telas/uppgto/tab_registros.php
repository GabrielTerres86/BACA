<? 
/*!
 * FONTE        : tab_registros.php						Última alteração:  19/09/2017
 * CRIAÇÃO      : Tiago
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Tabela que apresenta os detalhes
 * --------------
 * ALTERAÇÕES   :  17/11/2017 - Ajustes melhoria 271.3 (Tiago).
                    
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
		
		<legend><? echo "Remessas"; ?></legend>
		
		<div class="divRegistros">
		
			<table>
				<thead>
					<tr>
						<th>Nome Arquivo</th>
						<th>Data/Hora</th>
						<th>Cedente</th>
						<th>Valor</th>
					</tr>
				</thead>
				<tbody>
				
					<? foreach( $registros as $result ) {    ?>
						<tr onclick="selecionaRemessa(this);">	
							<td><span><? echo getByTagName($result->tags,'nmarquiv'); ?></span> <? echo getByTagName($result->tags,'nmarquiv'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dhdgerac'); ?></span> <? echo getByTagName($result->tags,'dhdgerac'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nmcedent'); ?></span> <? echo getByTagName($result->tags,'nmcedent'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'vltitulo'); ?></span><? echo getByTagName($result->tags,'vltitulo'); ?> </td>
							
							<input type="hidden" id="hdnmarquiv" name="hdnmarquiv" value="<? echo getByTagName($result->tags,'nmarquiv'); ?>" />
							<input type="hidden" id="hddhdgerac" name="hddhdgerac" value="<? echo getByTagName($result->tags,'dhdgerac'); ?>" />
							<input type="hidden" id="hdnmcedent" name="hdnmcedent" value="<? echo getByTagName($result->tags,'nmcedent'); ?>" />
							<input type="hidden" id="hdvltitulo" name="hdvltitulo" value="<? echo getByTagName($result->tags,'vltitulo');  ?>" />
							<input type="hidden" id="hddtvencto" name="hddtvencto" value="<? echo getByTagName($result->tags,'dtvencto'); ?>" />
							<input type="hidden" id="hddtdpagto" name="hddtdpagto" value="<? echo getByTagName($result->tags,'dtdpagto'); ?>" />
							<input type="hidden" id="hdnrconven" name="hdnrconven" value="<? echo getByTagName($result->tags,'nrconven'); ?>" />							
							<input type="hidden" id="hdcdocorre" name="hdcdocorre" value="<? echo getByTagName($result->tags,'cdocorre'); ?>" />
							<input type="hidden" id="hddsocorre" name="hddsocorre" value="<? echo getByTagName($result->tags,'dsocorre'); ?>" />
							<input type="hidden" id="hdnrnivel_urp" name="hdnrnivel_urp" value="<? echo getByTagName($result->tags,'nrnivel_urp'); ?>" />
							<input type="hidden" id="hdintipmvt_urp" name="hdintipmvt_urp" value="<? echo getByTagName($result->tags,'intipmvt_urp'); ?>" />
							<input type="hidden" id="hdnrremret_urp" name="hdnrremret_urp" value="<? echo getByTagName($result->tags,'nrremret_urp'); ?>" />
							<input type="hidden" id="hdnrseqarq_urp" name="hdnrseqarq_urp" value="<? echo getByTagName($result->tags,'nrseqarq_urp'); ?>" />
							<input type="hidden" id="hddscodbar" name="hddscodbar" value="<? echo getByTagName($result->tags,'dscodbar'); ?>" />
							<input type="hidden" id="hddslindig" name="hddslindig" value="<? echo getByTagName($result->tags,'dslindig'); ?>" />
							<input type="hidden" id="hddssituac" name="hddssituac" value="<? echo getByTagName($result->tags,'dssituac'); ?>" />
							<input type="hidden" id="hddsprotoc" name="hddsprotoc" value="<? echo getByTagName($result->tags,'dsprotoc'); ?>" />
							<input type="hidden" id="hdnrdocmto" name="hdnrdocmto" value="<? echo getByTagName($result->tags,'nrdocmto'); ?>" />
							<input type="hidden" id="hdnrseqaut" name="hdnrseqaut" value="<? echo getByTagName($result->tags,'nrseqaut'); ?>" />
							<input type="hidden" id="hddsinfor1" name="hddsinfor1" value="<? echo getByTagName($result->tags,'dsinfor1'); ?>" />
							<input type="hidden" id="hddsinfor2" name="hddsinfor2" value="<? echo getByTagName($result->tags,'dsinfor2'); ?>" />
							<input type="hidden" id="hddsinfor3" name="hddsinfor3" value="<? echo getByTagName($result->tags,'dsinfor3'); ?>" />
							<input type="hidden" id="hdcdtippro" name="hdcdtippro" value="<? echo getByTagName($result->tags,'cdtippro'); ?>" />
							<input type="hidden" id="hdnmprepos" name="hdnmprepos" value="<? echo getByTagName($result->tags,'nmprepos'); ?>" />
							<input type="hidden" id="hddttransa" name="hddttransa" value="<? echo getByTagName($result->tags,'dttransa'); ?>" />
							<input type="hidden" id="hdhrautent" name="hdhrautent" value="<? echo getByTagName($result->tags,'hrautent'); ?>" />
							<input type="hidden" id="hddtmvtolt" name="hddtmvtolt" value="<? echo getByTagName($result->tags,'dtmvtolt'); ?>" />
							<input type="hidden" id="hdqttotage" name="hdqttotage" value="<? echo getByTagName($result->tags,'qttotage'); ?>" />
							
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
		
		<label for="dtnmarquiv"><? echo utf8ToHtml('Nome do arquivo:') ?></label>
		<input type="text" id="dtnmarquiv" name="dtnmarquiv"/>
		
		<label for="dtdhdgerac"><? echo utf8ToHtml('Data/Hora da Transa&ccedil;&atilde;o:') ?></label>
		<input type="text" id="dtdhdgerac" name="dtdhdgerac"/>
		
		<label for="dtdscodbar"><? echo utf8ToHtml('C&oacute;digo de Barras:') ?></label>
		<input type="text" id="dtdscodbar" name="dtdscodbar"/>

		<label for="dtdslindig"><? echo utf8ToHtml('Linha Digit&aacute;vel:') ?></label>
		<input type="text" id="dtdslindig" name="dtdslindig"/>

		<label for="dtnmcedent"><? echo utf8ToHtml('Cedente:') ?></label>
		<input type="text" id="dtnmcedent" name="dtnmcedent"/>

		<label for="dtdtvencto"><? echo utf8ToHtml('Data do Vencimento:') ?></label>
		<input type="text" id="dtdtvencto" name="dtdtvencto"/>

		<label for="dtdtdpagto"><? echo utf8ToHtml('Agendado para:') ?></label>
		<input type="text" id="dtdtdpagto" name="dtdtdpagto"/>
		
		<label for="dtvltitulo"><? echo utf8ToHtml('Valor Pago:') ?></label>
		<input type="text" id="dtvltitulo" name="dtvltitulo"/>
		
		<label for="dtdssituac"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
		<input type="text" id="dtdssituac" name="dtdssituac"/>
		
		<label for="dtdsocorre"><? echo utf8ToHtml('Ocorr&ecirc;ncia:') ?></label>
		<input type="text" id="dtdsocorre" name="dtdsocorre"/>
		
	</fieldset>
	
</form>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscaRemessas(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscaRemessas(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistros','#divTabela').formataRodapePesquisa();
			
</script>