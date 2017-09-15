<? 
/*!
 * FONTE        : tabela_pagamento_prejuizo.php
 * CRIAÇÃO      : Andrey Formigari (MOUTS)
 * DATA CRIAÇÃO : 21/08/2017
 * OBJETIVO     : Realizar pagamento de prejuizo de contrato.
 
   ALTERACOES   : 
   
 */
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0;
	$dtpagto  = (isset($_POST['dtpagto'])) ? $_POST['dtpagto'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
 
	$xml2  = "<Root>";
	$xml2 .= " <Dados>";
	$xml2 .= "   <dtpagto>".$dtpagto."</dtpagto>";
	$xml2 .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml2 .= "   <nrctremp>".$nrctremp."</nrctremp>";	
	$xml2 .= " </Dados>";
	$xml2 .= "</Root>";

	$procedure2 = "BUSCA_VALORES";
	
	$xmlResult2 = mensageria($xml2, "PAGPRJ", $procedure2, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj2 = getObjectXML($xmlResult2);
	
	$aRegistros2 = $xmlObj2->roottag->tags;
	
	foreach ($aRegistros2 as $oEstorno) {
?>
<div id="divVlParcPreju " align="left" >
	<form id="frmVlParcPreju" name="frmVlParcPreju" class="formulario">
		<table width="100%">
			<tr>
				<td><label for="vlprincipal">&nbsp;&nbsp;<?php echo utf8ToHtml('Valor Principal:') ?></label></td>
				<td><input type="text" id="vlprincipal" name="vlprincipal" value="<? echo getByTagName($oEstorno->tags,'vlsdprej') ?>" disabled readonly class="moeda campo campoTelaSemBorda" /></td>
			</tr>
			<tr>
				<td><label for="vljuros">&nbsp;&nbsp;<?php echo utf8ToHtml('Juros:') ?></label></td>
				<td><input type="text" id="vljuros" name="vljuros" value="<? echo getByTagName($oEstorno->tags,'vlttjmpr') ?>" disabled readonly class="moeda campo campoTelaSemBorda" /></td>
			</tr>
			<tr>
				<td><label for="vlmulta">&nbsp;&nbsp;<?php echo utf8ToHtml('Multa:') ?></label></td>
				<td><input type="text" id="vlmulta" name="vlmulta" value="<? echo getByTagName($oEstorno->tags,'vlttmupr') ?>" disabled readonly class="moeda campo campoTelaSemBorda" /></td>
			</tr>
			<tr>
				<td><label for="vlpagto">&nbsp;&nbsp;<?php echo utf8ToHtml('Pagamento:') ?></label></td>
				<td><input type="text" id="vlpagto" name="vlpagto" value="" onkeyup="calcularSaldo()" class="moeda campo" /></td>
			</tr>
			<tr>
				<td><label for="vlabono">&nbsp;&nbsp;<?php echo utf8ToHtml('Abono:') ?></label></td>
				<td><input type="text" id="vlabono" name="vlabono" value="" onkeyup="calcularSaldo()" class="moeda campo" /></td>
			</tr>
			<tr>
				<td><label for="vlsaldo">&nbsp;&nbsp;<?php echo utf8ToHtml('Saldo:') ?></label></td>
				<td><input type="text" id="vlsaldo" disabled  name="vlsaldo" value="" disabled readonly class="moeda campo campoTelaSemBorda" /></td>
			</tr>
		</table>
	</form>
</div>
<?
	}
?>
<div id="divBotoes">
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao(''); return false;" />
	<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaPagamentoPreju(); return false;" />
</div>
<form class="formulario" id="frmAntecipapgto">
  <input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
</form>
