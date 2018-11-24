<? 
/*!
 * FONTE        : tab_sem_registro.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 21/12/2011 
 * OBJETIVO     : Tabela a consulta da tela COBRAN
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [03/12/2014] Jean Reddiga  (RKAM)   : De acordo com a circula 3.656 do Banco Central,substituir nomenclaturas Cedente
 *	             			             por Beneficiário e  Sacado por Pagador  Chamado 229313 (Jean Reddiga - RKAM).
 *
 * [11/10/2016] Odirlei Busana(AMcom)  : Inclusao dos campos de aviso por SMS. PRJ319 - SMS Cobrança (Odirlei - AMcom)
 *
 * [03/07/2017] Jean Michel  		   : Inclusao da funcao formataTabela(), PRJ340 (Jean Michel)
 */	
?>

<form action="<?php echo $UrlSite;?>telas/cobran/manter_rotina.php" method="post" id="frmExportarREM" name="frmExportarREM">
	<input type="hidden" id="operacao" name="operacao" value="ER">
	<input type="hidden" id="nrdconta" name="nrdconta" value="">
	<input type="hidden" id="ininrdoc" name="ininrdoc" value="">
	<input type="hidden" id="fimnrdoc" name="fimnrdoc" value="">
	<input type="hidden" id="consulta" name="consulta" value="2">
	<input type="hidden" id="tpconsul" name="tpconsul" value="">
	<input type="hidden" id="flgregis" name="flgregis" value="0">
	<input type="hidden" id="inestcri" name="inestcri" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<form id="frmTabela" class="formulario" >
	<fieldset>
	<legend>Boleto</legend>
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta/DV'); ?></th>
					<th><? echo utf8ToHtml('Tit.');  ?></th>
					<th><? echo utf8ToHtml('Emissao');  ?></th>
					<th><? echo utf8ToHtml('Retirada');  ?></th>
					<th><? echo utf8ToHtml('Convenio');  ?></th>
					<th><? echo utf8ToHtml('Boleto');  ?></th>
					<th><? echo utf8ToHtml('Valor Pago');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registro as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrdconta') ?></span>
							      <? echo formataContaDV(getByTagName($r->tags,'nrdconta')) ?>
								  <input type="hidden" id="dssituac" name="dssituac" value="<? echo getByTagName($r->tags,'dssituac') ?>" />								  
								  <input type="hidden" id="vltitulo" name="vltitulo" value="<? echo formataMoeda(getByTagName($r->tags,'vltitulo')) ?>" />								  
								  <input type="hidden" id="nmdsacad" name="nmdsacad" value="<? echo stringTabela(getByTagName($r->tags,'nmdsacad'),39,'maiuscula')  ?>" />								  
								  <input type="hidden" id="dsinssac" name="dsinssac" value="<? echo getByTagName($r->tags,'dsinssac') ?>" />								  
								  <input type="hidden" id="dtdpagto" name="dtdpagto" value="<? echo getByTagName($r->tags,'dtdpagto') ?>" />								  
								  <input type="hidden" id="dsdpagto" name="dsdpagto" value="<? echo getByTagName($r->tags,'dsdpagto') ?>" />								  
								  <input type="hidden" id="dtvencto" name="dtvencto" value="<? echo getByTagName($r->tags,'dtvencto') ?>" />								  
								  <input type="hidden" id="dsdoccop" name="dsdoccop" value="<? echo getByTagName($r->tags,'dsdoccop') ?>" />								  
								  <input type="hidden" id="dsorgarq" name="dsorgarq" value="<? echo getByTagName($r->tags,'dsorgarq') ?>" />								  
								  <input type="hidden" id="nrdctabb" name="nrdctabb" value="<? echo mascara(getByTagName($r->tags,'nrdctabb'), '####.###.#') ?>" />								  
								  
                                  <!-- Aviso SMS -->
                                  <input type="hidden" id="inavisms" name="inavisms" value="<? echo getByTagName($r->tags,'inavisms') ?>" />
                                  <input type="hidden" id="insmsant" name="insmsant" value="<? echo getByTagName($r->tags,'insmsant') ?>" />
                                  <input type="hidden" id="insmsvct" name="insmsvct" value="<? echo getByTagName($r->tags,'insmsvct') ?>" />
                                  <input type="hidden" id="insmspos" name="insmspos" value="<? echo getByTagName($r->tags,'insmspos') ?>" />
                                  
                                  <input type="hidden" id="dsavisms" name="dsavisms" value="<? echo getByTagName($r->tags,'dsavisms') ?>" />
                                  <input type="hidden" id="dssmsant" name="dssmsant" value="<? echo getByTagName($r->tags,'dssmsant') ?>" />
                                  <input type="hidden" id="dssmsvct" name="dssmsvct" value="<? echo getByTagName($r->tags,'dssmsvct') ?>" />
                                  <input type="hidden" id="dssmspos" name="dssmspos" value="<? echo getByTagName($r->tags,'dssmspos') ?>" />
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'idseqttl') ?></span>
							      <? echo getByTagName($r->tags,'idseqttl') ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt') ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtretcob')) ?></span>
							      <? echo getByTagName($r->tags,'dtretcob') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrcnvcob') ?></span>
							      <? echo getByTagName($r->tags,'nrcnvcob') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdocmto') ?></span>
							      <? echo getByTagName($r->tags,'nrdocmto') ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vldpagto'),'MOEDA')  ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vldpagto')) ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td>
					<?
						
						//
						if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
						
						// Se a paginação não está na primeira, exibe botão voltar
						if ($nriniseq > 1) { 
							?> <a class='paginacaoAnt'><<< Anterior</a> <? 
						} else {
							?> &nbsp; <?
						}
					?>
				</td>
				<td>
					<?
						if (isset($nriniseq)) { 
							?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
						}
					?>
				</td>
				<td>
					<?
						// Se a paginação não está na &uacute;ltima página, exibe botão proximo
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
	
	<div id="linha1">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Status:'); ?></li>
	<li id="dssituac"></li>
	<li><? echo utf8ToHtml('Valor Boleto:'); ?></li>
	<li id="vltitulo"></li>
	</ul>
	</div>

	<div id="linha2">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Pagador:'); ?></li>
	<li id="nmdsacad"></li>
	<li><? echo utf8ToHtml('CPF/CNPJ:'); ?></li>
	<li id="dsinssac"></li>
	</ul>
	</div>	
	
	<div id="linha3">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Dt.Pagamento:'); ?></li>
	<li id="dtdpagto"></li>
	<li><? echo utf8ToHtml('Ds.Pagamento:'); ?></li>
	<li id="dsdpagto"></li>
	</ul>
	</div>	

	<div id="linha4">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Dt.Vencimento:'); ?></li>
	<li id="dtvencto"></li>
	<li><? echo utf8ToHtml('Doc.Cooperado:'); ?></li>
	<li id="dsdoccop"></li>
	</ul>
	</div>	

	<div id="linha5">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Orig. Arquivo:'); ?></li>
	<li id="dsorgarq"></li>
	<li><? echo utf8ToHtml('Conta Base:'); ?></li>
	<li id="nrdctabb"></li>
	</ul>
	</div>
	
	<div id="linha6">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Cód. Barras:'); ?></li>
	<li id="cdbarras"></li>
	</ul>
	</div>
	
	<div id="linha7">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Linha Digitável:'); ?></li>
	<li id="lindigit"></li>
	</ul>
	</div>
	
	<div id="linha6">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Cód. Barras:'); ?></li>
	<li id="cdbarras"></li>
	</ul>
	</div>
	
	<div id="linha7">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Linha Digitável:'); ?></li>
	<li id="lindigit"></li>
	</ul>
	</div>
	
	</fieldset>
</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<?php
	if ( $qtregist > 0 ) {
	?>
		<a href="#" class="botao" onclick="buscaExportar(); return false;">Exportar Consulta</a>
		<?php if ($consulta == 2) { ?>
		<a href="#" class="botao" onclick="geraRemessa(false); return false;">Gerar Arquivo Remessa</a>
		<?php } ?>
	<?php
	}
	?>
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".$operacao."','".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".$operacao."','".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divRegistros','#divTela').formataTabela();
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>

