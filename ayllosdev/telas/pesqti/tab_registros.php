<? 
/*!
 * FONTE        : tab_registros.php
 * CRIAÇÃO      : Adriano
 * DATA CRIAÇÃO : 18/09/2015
 * OBJETIVO     : Tabela que apresenta a consulta PESQTI
 * --------------
 * ALTERAÇÕES   : 12/05/2016 - Adicionar o campo de linha digitavel (Douglas - Chamado 426870)
 *
 *				        19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS 
 *					  		             pelo InternetBanking (Projeto 338 - Lucas Lunelli)
 *
 *                18/01/2018 - Alterações referentes ao PJ406.
 *
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<fieldset id="Informacoes">

	<legend><? if($tpdpagto == "yes"){echo "Titulo(s)";}else{echo "Fatura(s)";} ?></legend>
	
	<div class="divRegistros">
	
	    <table>
			<thead>
 			    <tr>
					<th>PA</th>
					<th>Valor</th>
					<th>Operador</th>
					<th>Lote</th>
			    </tr>
			</thead>
			<tbody>
				<? foreach( $registros as $result ) {    ?>
				    <tr>	
						<td><span><? echo getByTagName($result->tags,'cdagenci'); ?></span> <? echo getByTagName($result->tags,'cdagenci'); ?> </td>
						<td><span><? echo str_replace(",",".",getByTagName($result->tags,'vldpagto')); ?></span><? echo number_format(str_replace(",",".",getByTagName($result->tags,'vldpagto')),2,",","."); ?> </td>
						<td><span><? echo getByTagName($result->tags,'nmoperad'); ?></span><? echo getByTagName($result->tags,'nmoperad'); ?> </td>
						<td><span><? echo getByTagName($result->tags,'nrdolote'); ?></span><? echo formataNumericos('zzz.zz9',getByTagName($result->tags,'nrdolote'),'.'); ?> </td>	
						<input type="hidden" id="nrautdoc" name="nrautdoc" value="<? echo formataNumericos('zzz.zz9',getByTagName($result->tags,'nrautdoc'),'.') ?>" />
						<input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo formataNumericos(($tpdpagto == "T" ? 'zzz.zzz.zz9' : 'zz.zzz.zzz.zzz.zzz.zzz.zzz.zzz.zzz.zzz.zzz.zzz.zz9'),getByTagName($result->tags,'nrdocmto'),'.') ?>" />								  
						<input type="hidden" id="flgpgdda" name="flgpgdda" value="<? echo getByTagName($result->tags,'flgpgdda') ?>" />								  
						<input type="hidden" id="cdbandst" name="cdbandst" value="<? echo getByTagName($result->tags,'cdbandst')." - ".getByTagName($result->tags,'nmextbcc') ?>" />								  
						<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo formataNumericos('zzzz.zzz-9',getByTagName($result->tags,'nrdconta'),'.-') ?>" />								  
						<input type="hidden" id="nmresage" name="nmresage" value="<? echo getByTagName($result->tags,'nmresage') ?>" />
						<input type="hidden" id="dscodbar" name="dscodbar" value="<? echo getByTagName($result->tags,'dscodbar') ?>" />
						<input type="hidden" id="dslindig" name="dslindig" value="<? echo getByTagName($result->tags,'dslindig') ?>" />
						<input type="hidden" id="nmextbcc" name="nmextbcc" value="<? echo getByTagName($result->tags,'nmextbcc') ?>" />								  															  						
						<input type="hidden" id="dspactaa" name="dspactaa" value="<? echo getByTagName($result->tags,'dspactaa') ?>" />	
						<input type="hidden" id="vlconfoz" name="vlconfoz" value="<? echo getByTagName($result->tags,'vlconfoz') ?>" />	
						<input type="hidden" id="insitfat" name="insitfat" value="<? echo getByTagName($result->tags,'insitfat') ?>" />	
						<input type="hidden" id="nrdolote" name="nrdolote" value="<? echo getByTagName($result->tags,'nrdolote') ?>" />	
						<input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($result->tags,'cdagenci') ?>" />	
						<input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo getByTagName($result->tags,'cdbandst') ?>" />
						<input type="hidden" id="dtdpagto" name="dtdpagto" value="<? echo $dtdpagto?>" />	
						<input type="hidden" id="cdhiscxa" name="cdhiscxa" value="<? echo $cdhiscxa ?>" />
						
						<input type="hidden" id="dtapurac" name="dtapurac" value="<? echo getByTagName($result->tags,'dtapurac') ?>" />
						<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($result->tags,'nrcpfcgc') ?>" />
						<input type="hidden" id="cdtribut" name="cdtribut" value="<? echo getByTagName($result->tags,'cdtribut') ?>" />
						<input type="hidden" id="nrrefere" name="nrrefere" value="<? echo getByTagName($result->tags,'nrrefere') ?>" />
						<input type="hidden" id="dtlimite" name="dtlimite" value="<? echo getByTagName($result->tags,'dtlimite') ?>" />
						<input type="hidden" id="vllanmto" name="vllanmto" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vllanmto')),2,",","."); ?>" />																	
						<input type="hidden" id="vlrmulta" name="vlrmulta" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlrmulta')),2,",","."); ?>" />
						<input type="hidden" id="vlrjuros" name="vlrjuros" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlrjuros')),2,",","."); ?>" />
						<input type="hidden" id="vlrtotal" name="vlrtotal" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlrtotal')),2,",","."); ?>" />
						<input type="hidden" id="vlrecbru" name="vlrecbru" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlrecbru')),2,",","."); ?>" />
						<input type="hidden" id="vlpercen" name="vlpercen" value="<? echo number_format(str_replace(",",".",getByTagName($result->tags,'vlpercen')),2,",","."); ?>" />
						<input type="hidden" id="nmempres" name="nmempres" value="<? echo getByTagName($result->tags,'nmempres') ?>" />
						<input type="hidden" id="dscptdoc" name="dscptdoc" value="<? echo getByTagName($result->tags,'dscptdoc') ?>" />
						<input type="hidden" id="dsnomfon" name="dsnomfon" value="<? echo getByTagName($result->tags,'dsnomfon') ?>" />
		
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
					/ Total: <? echo number_format(str_replace(",",".",$vlrtotal ),2,",","."); ?>
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

<script type="text/javascript">
	//Se for opcao de Alteração, exibe botão ALTERAR
	if ('<?echo $cddopcao;?>' == 'A'){
		$('#btAlterar','#divBotoes').css('display','inline');
		$('#btConsultar','#divBotoes').css('display','none');
		
	} else {
		$('#btAlterar','#divBotoes').css('display','none');
		$('#btConsultar','#divBotoes').css('display','none');
	}
	$('#btVoltar','#divBotoes').css('display','inline');
	
	if ($("#cdhiscxa","#frmFiltroPesqti").hasClass("campoErro")){
	
		$('#btVoltar','#divBotoes').css('display','none');
		$('#btAlterar','#divBotoes').css('display','none');
		
	}
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		obtemConsulta(<? echo ($nriniseq - $nrregist);?>,<?php echo $nrregist;?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		obtemConsulta(<? echo ($nriniseq + $nrregist);?>,<?php echo $nrregist;?>);
		
	});		
	$('#divPesquisaRodape','#divConsulta').formataRodapePesquisa();

	formataFormularios();
	controlaLayout("1");	
			
</script>
