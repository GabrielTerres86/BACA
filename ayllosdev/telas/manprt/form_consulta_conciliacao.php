<? 
/*!
 * FONTE        : form_consulta_consiliacao.php
 * CRIA��O      : Helinton Steffens - (Supero)
 * DATA CRIA��O : 29/03/2018 
 * OBJETIVO     : Tabela que apresenta as conciliacoes realizadas
 * 
 *	08/07/2019 - Alterações referetentes a RITM13002 (Daniel Lombardi - Mout'S)
 */	
?>

<form id="frmTabela" class="formulario" >
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Cart&oacuterio');  ?></th>
                    <th><? echo utf8ToHtml('Informações TED');  ?></th>
                    <th><? echo utf8ToHtml('Coop.');  ?></th>
                    <th><? echo utf8ToHtml('Conv.');  ?></th>
                    <th><? echo utf8ToHtml('Data conc.');  ?></th>
                    <th><? echo utf8ToHtml('Valor T&iacutetulo');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach ($registro as $reg) { if (!getByTagName($reg->tags,'dtconcilicao')) { continue; } ?>
					<tr>
						
						<td><span><? echo getByTagName($reg->tags,'nmcartorio') ?></span>
							      <? echo getByTagName($reg->tags,'nmcartorio') ?>
								  <input type="hidden" id="vlconctotal" value="<? echo getByTagName($reg->tags,'vltotalted') ?>" />
								  <input type="hidden" id="infotedscomp" value="<? echo getByTagName($reg->tags,'inftedscomp') ?>" />
                                  <input type="hidden" id="infoteds" value="<? echo getByTagName($reg->tags,'infteds') ?>" />
  								  <input type="hidden" id="cartorio" value="<? echo getByTagName($reg->tags,'nmcartorio') ?>" />
								  <input type="hidden" id="valorted" value="<? echo getByTagName($reg->tags,'vllanmto') ?>" />
								  <input type="hidden" id="convenio" value="<? echo getByTagName($reg->tags,'nrcnvcob') ?>" />
								  <input type="hidden" id="cooperativa" value="<? echo getByTagName($reg->tags,'nmrescop') ?>" />
								  <input type="hidden" id="conta" value="<? echo getByTagName($reg->tags,'nrdconta') ?>" />
								  <input type="hidden" id="dataconc" value="<? echo getByTagName($reg->tags,'dtconcilicao') ?>" />
								  <input type="hidden" id="valortit" value="<? echo getByTagName($reg->tags,'vltitulo') ?>" />
								  <input type="hidden" id="datacomp" value="<? echo getByTagName($reg->tags,'dtdproc') ?>" />
								  <input type="hidden" id="banco" value="<? echo getByTagName($reg->tags,'cdbccxlt') ?>" />
								  <input type="hidden" id="agencia" value="<? echo getByTagName($reg->tags,'cdagenci') ?>" />
								  <input type="hidden" id="cidade" value="<? echo getByTagName($reg->tags,'dscidade') ?>" />
								  <input type="hidden" id="estado" value="<? echo getByTagName($reg->tags,'cdestado') ?>" />
								  <input type="hidden" id="dtmvtolt" value="<? echo getByTagName($reg->tags,'dtmvtolt') ?>" />

						</td>
                        <td><span><? echo getByTagName($reg->tags,'infteds') ?></span>
							      <? echo getByTagName($reg->tags,'infteds') ?>
						</td>
                        <td><span><? echo getByTagName($reg->tags,'nmrescop') ?></span>
							      <? echo getByTagName($reg->tags,'nmrescop') ?>
						</td>
						<td><span><? echo getByTagName($reg->tags,'nrcnvcob') ?></span>
							      <? echo getByTagName($reg->tags,'nrcnvcob') ?>
						</td>
						<td><span><? echo getByTagName($reg->tags,'dtconcilicao') ?></span>
							      <? echo getByTagName($reg->tags,'dtconcilicao') ?>
						</td>
						<td><span><? echo getByTagName($reg->tags,'vltitulo') ?></span>
							      <? echo number_format(getByTagName($reg->tags,'vltitulo'), 2, ',', '.') ?>
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
						if (isset($qtregist) and $qtregist == 0) {
                            $nriniseq = 0;
                        }

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
	<li><? echo utf8ToHtml('Cart&oacuterio:'); ?></li>
	<li id="dscartorio"></li>
	<li><? echo utf8ToHtml('Data Conciliação:'); ?></li>
	<li id="dtconcilacao"></li>
	</ul>
	</div>

	<div id="linha2">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Banco/Ag&ecircncia:'); ?></li>
	<li id="cdbanpag"></li>
	<li><? echo utf8ToHtml('Valor T&iacutetulo:'); ?></li>
	<li id="vltitul"></li>
	</ul>
	</div>

    <div id="linha3">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Cidade:'); ?></li>
	<li id="cdcidade"></li>
	<li><? echo utf8ToHtml('Estado:'); ?></li>
	<li id="cdestado"></li>
	</ul>
	</div>	
	
	<div id="linha4">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Cooperativa:'); ?></li>
	<li id="cdcoope"></li>
	<li><? echo utf8ToHtml('Convênio:'); ?></li>
	<li id="nrconve"></li>
	</ul>
	</div>	

	<div id="linha5">
	<ul style="padding-bottom: 40px" class="complemento">
	<li><? echo utf8ToHtml('Informações TED:'); ?></li> 
	<li id="inftedcomp"></li> 
	<li><? echo utf8ToHtml('Total conciliado:'); ?></li>
	<li id="vltotconc"></li>
	</ul>
	</div>	

</form>

<div id="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<?php
	if ( $qtregist > 0 ) {
	?>
		<a href="#" class="botao" onclick="exportarConsultaPDF(); return false;">Exportar PDF</a>
		<a href="#" class="botao" onclick="exportarConsultaCSV(); return false;">Exportar CSV</a>
		<!--<a href="#" class="botao" onclick="buscaExportar(); return false;">Devolver</a>
		<a href="#" class="botao" onclick="geraCartaAnuencia(); return false;">Extornar</a>-->
	<?php
	}
	?>
</div>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_conciliacao_csv.php" method="post" id="frmExportarCSV" name="frmExportarCSV">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="inivlpro" id="inivlpro" value="<?php echo $inivlpro; ?>">
	<input type="hidden" name="fimvlpro" id="fimvlpro" value="<?php echo $fimvlpro; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_conciliacao_pdf.php" method="post" id="frmExportarPDF" name="frmExportarPDF">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="inivlpro" id="inivlpro" value="<?php echo $inivlpro; ?>">
	<input type="hidden" name="fimvlpro" id="fimvlpro" value="<?php echo $fimvlpro; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		realizaoConsultaConciliacao(<? echo ($nriniseq - $nrregist).",".$nrregist; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		realizaoConsultaConciliacao(<? echo ($nriniseq + $nrregist).",".$nrregist; ?>);
	});	
	
	$('#divRegistros','#divTela').formataTabela();
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>