<? 
/*!
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 21/12/2011 
 * OBJETIVO     : Tabela que apresenta os contrato
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [03/12/2014] Jean Reddiga  (RKAM)   : De acordo com a circula 3.656 do Banco Central,substituir nomenclaturas Cedente
 *	             			             por Beneficiário e  Sacado por Pagador  Chamado 229313 (Jean Reddiga - RKAM).
 * [04/05/2015] Lucas Reinert (CECRED) : Incluido campo dsemiten - Projeto DP 219 - Cooperativa Emite e Expede.
 *
 *			    30/12/2015 - Alterações Referente Projeto Negativação Serasa (Daniel)	
 *
 *              11/10/2016 - Inclusao dos campos de aviso por SMS 
 *                           PRJ319 - SMS Cobrança (Odirlei - AMcom)
*               08/01/2017 - Inclusao do campo flgdprot (Heitor - Mouts) - Chamado 574161 
 *              11/10/2016 - Inclusao dos campos de aviso por SMS 
 *                           PRJ319 - SMS Cobrança (Odirlei - AMcom)
 *              08/05/2019 - inc0012536 adicionada a validação do código da espécie 2 (duplicata de serviço) juntamente com a UF 
 *                           não autorizada. Duplicatas de serviço dos estados listados não podem ir para protesto (Carlos)
 */	
?>

<form action="<?php echo $UrlSite;?>telas/cobran/manter_rotina.php" method="post" id="frmExportarREM" name="frmExportarREM">
	<input type="hidden" id="operacao" name="operacao" value="ER">
	<input type="hidden" id="nrdconta" name="nrdconta" value="">
	<input type="hidden" id="ininrdoc" name="ininrdoc" value="">
	<input type="hidden" id="fimnrdoc" name="fimnrdoc" value="">
	<input type="hidden" id="consulta" name="consulta" value="2">
	<input type="hidden" id="tpconsul" name="tpconsul" value="">
	<input type="hidden" id="flgregis" name="flgregis" value="1">
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
					<th><? echo utf8ToHtml('Nro Docto'); ?></th>
					<th><? echo utf8ToHtml('Boleto');  ?></th>
					<th><? echo utf8ToHtml('Emissao');  ?></th>
					<th><? echo utf8ToHtml('Vencto');  ?></th>
					<th><? echo utf8ToHtml('Dt. Pagto');  ?></th>
					<th><? echo utf8ToHtml('Valor Pago');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registro as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'dsdoccop') ?></span>
							      <? echo getByTagName($r->tags,'dsdoccop') ?>
								  <input type="hidden" id="dssituac" name="dssituac" value="<? echo getByTagName($r->tags,'dssituac') ?> <? echo getByTagName($r->tags,'dtsitcrt') ?>" />								  
								  <input type="hidden" id="vltitulo" name="vltitulo" value="<? echo formataMoeda(getByTagName($r->tags,'vltitulo')) ?>" />								  
								  <input type="hidden" id="nrcnvcob" name="nrcnvcob" value="<? echo getByTagName($r->tags,'nrcnvcob') ?>" />								  
								  <input type="hidden" id="cdbanpag" name="cdbanpag" value="<? echo getByTagName($r->tags,'cdbanpag') ?> / <? echo getByTagName($r->tags,'cdagepag') ?>" />								  
								  <input type="hidden" id="nmdsacad" name="nmdsacad" value="<? echo stringTabela(getByTagName($r->tags,'nmdsacad'),41,'maiuscula') ?>" />								  
								  <input type="hidden" id="dsdpagto" name="dsdpagto" value="<? echo getByTagName($r->tags,'dsdpagto') ?>" />								  
								  <input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($r->tags,'nrdconta') ?>" />								  
								  <input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo stringTabela(formataContaDV(getByTagName($r->tags,'nrdconta')) ." - ". getByTagName($r->tags,'nmprimtl'),41,'maiuscula') ?> " />								  
								  <input type="hidden" id="nrnosnum" name="nrnosnum" value="<? echo getByTagName($r->tags,'nrnosnum') ?>" />								  
								  <input type="hidden" id="dsorgarq" name="dsorgarq" value="<? echo getByTagName($r->tags,'dsorgarq') ?>" />								  
								  <input type="hidden" id="nrdctabb" name="nrdctabb" value="<? echo getByTagName($r->tags,'nrdctabb') ?>" />								  
								  <input type="hidden" id="insitcrt" name="insitcrt" value="<? echo getByTagName($r->tags,'insitcrt') ?>" />									  
								  
                                  <input type="hidden" id="cddespec" name="cddespec" value="<? echo getByTagName($r->tags,'cddespec') ?>" />
                                  
								  <input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($r->tags,'cdcooper') ?>" />								  
								  <input type="hidden" id="cdsituac" name="cdsituac" value="<? echo getByTagName($r->tags,'cdsituac') ?>" />								  
								  <input type="hidden" id="dssituac" name="dssituac" value="<? echo getByTagName($r->tags,'dssituac') ?>" />								  
								  <input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo getByTagName($r->tags,'nrdocmto') ?>" />								  
								  <input type="hidden" id="nrinssac" name="nrinssac" value="<? echo getByTagName($r->tags,'nrinssac') ?>" />								  
								  <input type="hidden" id="dsdoccop" name="dsdoccop" value="<? echo getByTagName($r->tags,'dsdoccop') ?>" />								  
								  <input type="hidden" id="flgregis" name="flgregis" value="<? echo getByTagName($r->tags,'flgregis') ?>" />								  
								  <input type="hidden" id="flgcbdda" name="flgcbdda" value="<? echo getByTagName($r->tags,'flgcbdda') ?>" />								  
								  
								  <input type="hidden" id="flgsacad" name="flgsacad" value="" />								  
								  
								  <input type="hidden" id="dsendsac" name="dsendsac" value="<? echo getByTagName($r->tags,'dsendsac') ?>" />								  
								  <input type="hidden" id="complend" name="complend" value="<? echo getByTagName($r->tags,'complend') ?>" />								  
								  <input type="hidden" id="nmbaisac" name="nmbaisac" value="<? echo getByTagName($r->tags,'nmbaisac') ?>" />								  
								  <input type="hidden" id="nmcidsac" name="nmcidsac" value="<? echo getByTagName($r->tags,'nmcidsac') ?>" />								  
								  <input type="hidden" id="cdufsaca" name="cdufsaca" value="<? echo getByTagName($r->tags,'cdufsaca') ?>" />								  
								  <input type="hidden" id="nrcepsac" name="nrcepsac" value="<? echo getByTagName($r->tags,'nrcepsac') ?>" />								  
								  <input type="hidden" id="dscjuros" name="dscjuros" value="<? echo getByTagName($r->tags,'dscjuros') ?>" />								  
								  <input type="hidden" id="dscmulta" name="dscmulta" value="<? echo getByTagName($r->tags,'dscmulta') ?>" />								  
								  <input type="hidden" id="dscdscto" name="dscdscto" value="<? echo getByTagName($r->tags,'dscdscto') ?>" />								  
								  <input type="hidden" id="dtdocmto" name="dtdocmto" value="<? echo getByTagName($r->tags,'dtdocmto') ?>" />								  
								  <input type="hidden" id="dsdespec" name="dsdespec" value="<? echo getByTagName($r->tags,'dsdespec') ?>" />								  
								  <input type="hidden" id="flgaceit" name="flgaceit" value="<? echo getByTagName($r->tags,'flgaceit') ?>" />								  
								  <input type="hidden" id="dsemiten" name="dsemiten" value="<? echo getByTagName($r->tags,'dsemiten') ?>" />								  
								  <input type="hidden" id="dtvencto" name="dtvencto" value="<? echo getByTagName($r->tags,'dtvencto') ?>" />								  
								  <input type="hidden" id="vldesabt" name="vldesabt" value="<? echo formataMoeda(getByTagName($r->tags,'vldesabt')) ?>" />								  
								  <input type="hidden" id="qtdiaprt" name="qtdiaprt" value="<? echo getByTagName($r->tags,'qtdiaprt') ?>" />								  
								  <input type="hidden" id="dtdpagto" name="dtdpagto" value="<? echo getByTagName($r->tags,'dtdpagto') ?>" />								  
								  <input type="hidden" id="vldpagto" name="vldpagto" value="<? echo formataMoeda(getByTagName($r->tags,'vldpagto')) ?>" />								  
								  <input type="hidden" id="vljurmul" name="vljurmul" value="<? echo formataMoeda(getByTagName($r->tags,'vljurmul')) ?>" />								  
								  <input type="hidden" id="cdbandoc" name="cdbandoc" value="<? echo getByTagName($r->tags,'cdbandoc') ?>" />								  
								  <input type="hidden" id="cdtpinsc" name="cdtpinsc" value="<? echo getByTagName($r->tags,'cdtpinsc') ?>" />								  
								  <input type="hidden" id="inserasa" name="inserasa" value="<? echo getByTagName($r->tags,'inserasa') ?>" />	
								  <input type="hidden" id="flserasa" name="flserasa" value="<? echo getByTagName($r->tags,'flserasa') ?>" />
								  <input type="hidden" id="qtdianeg" name="qtdianeg" value="<? echo getByTagName($r->tags,'qtdianeg') ?>" />
								  <input type="hidden" id="flgdprot" name="flgdprot" value="<? echo getByTagName($r->tags,'flgdprot') ?>" />
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
						<td><span><? echo getByTagName($r->tags,'nrdocmto') ?></span>
							      <? echo getByTagName($r->tags,'nrdocmto') ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt') ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtvencto')) ?></span>
							      <? echo getByTagName($r->tags,'dtvencto') ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtdpagto')) ?></span>
							      <? echo getByTagName($r->tags,'dtdpagto') ?>
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
	<li><? echo utf8ToHtml('Convenio:'); ?></li>
	<li id="nrcnvcob"></li>
	<li><? echo utf8ToHtml('Bco/Agencia:'); ?></li>
	<li id="cdbanpag"></li>
	</ul>
	</div>	
	
	<div id="linha3">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Pagador:'); ?></li>
	<li id="nmdsacad"></li>
	<li><? echo utf8ToHtml('Ds.Pagamento:'); ?></li>
	<li id="dsdpagto"></li>
	</ul>
	</div>	

	<div id="linha4">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Conta/DV:'); ?></li>
	<li id="nmprimtl"></li>
	<li><? echo utf8ToHtml('Nosso Num:'); ?></li>
	<li id="nrnosnum"></li>
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
	
	</fieldset>
</form>
<style>
	#divBotoes a.botao {
		margin-top: 3px;
	}
</style>
<div id="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<?php
	if ( $qtregist > 0 ) {
	?>
		<a href="#" class="botao" onclick="buscaConsulta('log'); return false;">Log Boleto</a>
		<a href="#" class="botao" onclick="buscaConsulta('instrucoes'); return false;"><? echo utf8ToHtml('Instruções');  ?></a>
		<a href="#" class="botao" onclick="buscaExportar('C'); return false;">Exportar Consulta</a>
		<?php if ($consulta == 2) { ?>
		<a href="#" class="botao" onclick="geraRemessa(false); return false;">Gerar Arquivo Remessa</a>
		<?php } ?>
		<a href="#" class="botao" onclick="geraCartaAnuencia(); return false;"><? echo utf8ToHtml('Imprimir carta anuência');  ?></a>
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