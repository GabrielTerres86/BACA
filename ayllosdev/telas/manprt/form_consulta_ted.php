<? 
/*!
 * FONTE        : form_consulta_ted.php
 * CRIA��O      : Helinton Steffens - (Supero)
 * DATA CRIA��O : 14/03/2018 
 * OBJETIVO     : Tabela que apresenta as TED recebidas
 */	
?>

<form id="frmTabela" class="formulario" >
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Nome remet.');  ?></th>
					<th><? echo utf8ToHtml('CPF/CNPJ');  ?></th>
					<th><? echo utf8ToHtml('Banco');  ?></th>
					<th><? echo utf8ToHtml('Ag&ecircncia');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Dt. receb.');  ?></th>
                    <th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registro as $r ) { ?>
					<tr>
						
						<td><span><? echo getByTagName($r->tags,'nmremetente') ?></span>
							      <? echo getByTagName($r->tags,'nmremetente') ?>
								  <input type="hidden" id="nmcartorioflgcbdda" name="nmcartorio" value="<? echo getByTagName($r->tags,'nmcartorio') ?>" />
								  <input type="hidden" id="nmremetente" name="nmremetente" value="<? echo getByTagName($r->tags,'nmremetente') ?>" />
								  <input type="hidden" id="cnpj_cpf" name="cnpj_cpf" value="<? echo getByTagName($r->tags,'cnpj_cpf') ?>" />
								  <input type="hidden" id="banco" name="banco" value="<? echo getByTagName($r->tags,'banco') ?>" />
								  <input type="hidden" id="agencia" name="agencia" value="<? echo getByTagName($r->tags,'agencia') ?>" />
								  <input type="hidden" id="conta" name="conta" value="<? echo getByTagName($r->tags,'conta') ?>" />
								  <input type="hidden" id="dtrecebimento" name="dtrecebimento" value="<? echo getByTagName($r->tags,'dtrecebimento') ?>" />
								  <input type="hidden" id="valor" name="valor" value="<? echo getByTagName($r->tags,'valor') ?>" />
								  <input type="hidden" id="estado" name="estado" value="<? echo getByTagName($r->tags,'estado') ?>" />
								  <input type="hidden" id="cidade" name="cidade" value="<? echo getByTagName($r->tags,'cidade') ?>" />
								  <input type="hidden" id="status" name="status" value="<? echo getByTagName($r->tags,'status') ?>" />
						</td>
                        <td><span><? echo getByTagName($r->tags,'cnpj_cpf') ?></span>
							      <? echo getByTagName($r->tags,'cnpj_cpf') ?>
						</td>
                        <td><span><? echo getByTagName($r->tags,'banco') ?></span>
							      <? echo getByTagName($r->tags,'banco') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'agencia') ?></span>
							      <? echo getByTagName($r->tags,'agencia') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'conta') ?></span>
							      <? echo getByTagName($r->tags,'conta') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dtrecebimento') ?></span>
							      <? echo getByTagName($r->tags,'dtrecebimento') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'valor') ?></span>
							      <? echo getByTagName($r->tags,'valor') ?>
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
	<li><? echo utf8ToHtml('Cart&oacuterio:'); ?></li>
	<li id="dscartorio"></li>
	<li><? echo utf8ToHtml('Valor da Ted:'); ?></li>
	<li id="vlted"></li>
	</ul>
	</div>

	<div id="linha2">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Nome do remetente:'); ?></li>
	<li id="nmremetente"></li>
	<li><? echo utf8ToHtml('Cpf/Cnpj:'); ?></li>
	<li id="cpfcnpj"></li>
	</ul>
	</div>	
	
	<div id="linha3">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Banco/Ag&ecircncia:'); ?></li>
	<li id="cdbanpag"></li>
	<li><? echo utf8ToHtml('Conta:'); ?></li>
	<li id="nrconta"></li>
	</ul>
	</div>	

	<div id="linha4">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Data:'); ?></li>
	<li id="dtrecebimento"></li>
	<li><? echo utf8ToHtml('Status:'); ?></li>
	<li id="dsstatus"></li>
	</ul>
	</div>	

	<div id="linha5">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Cidade:'); ?></li>
	<li id="cdcidade"></li>
	<li><? echo utf8ToHtml('Estado:'); ?></li>
	<li id="cdestado"></li>
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
		<a href="#" class="botao" onclick="buscaExportar(); return false;">Devolver</a>
		<a href="#" class="botao" onclick="geraCartaAnuencia(); return false;">Extornar</a>
	<?php
	}
	?>
</div>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_ted_csv.php" method="post" id="frmExportarCSV" name="frmExportarCSV">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="inivlpro" id="inivlpro" value="<?php echo $inivlpro; ?>">
	<input type="hidden" name="fimvlpro" id="fimvlpro" value="<?php echo $fimvlpro; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_ted_pdf.php" method="post" id="frmExportarPDF" name="frmExportarPDF">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="inivlpro" id="inivlpro" value="<?php echo $inivlpro; ?>">
	<input type="hidden" name="fimvlpro" id="fimvlpro" value="<?php echo $fimvlpro; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

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