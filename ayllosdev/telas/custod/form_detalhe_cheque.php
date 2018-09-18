<?
/*!
 * FONTE        : form_detalhe_cheque.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 23/09/2016
 * OBJETIVO     : Tela de exibição detalhamento de cheques
 * --------------
 * ALTERAÇÕES   :
 */		

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');
isPostMethod();		

// Guardo os parâmetos do POST em variáveis	
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '';
$cddbanco = (isset($_POST['cddbanco'])) ? $_POST['cddbanco'] : 0;
$cdagectl = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
$nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0;
$nrcheque = (isset($_POST['nrcheque'])) ? $_POST['nrcheque'] : 0;
$vlcheque = (isset($_POST['vlcheque'])) ? $_POST['vlcheque'] : 0;
$nrconven = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0;
$nrremret = (isset($_POST['nrremret'])) ? $_POST['nrremret'] : 0;
$intipmvt = (isset($_POST['intipmvt'])) ? $_POST['intipmvt'] : 0;
$dsdocmc7 = (isset($_POST['dsdocmc7'])) ? $_POST['dsdocmc7'] : '';
$dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '';

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <nrremret>".$nrremret."</nrremret>";
$xml .= "   <intipmvt>".$intipmvt."</intipmvt>";
$xml .= "   <dsdocmc7>".$dsdocmc7."</dsdocmc7>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_BUSCA_DETALHE_CHEQUE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);		
//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	exit();
}

if(strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){	
	$nrcpfcgc = $xmlObj->roottag->tags[0]->tags[0]->cdata;
	$dsemiten = $xmlObj->roottag->tags[0]->tags[1]->cdata;
	$cdagenci = $xmlObj->roottag->tags[0]->tags[2]->cdata;
	$cdbccxlt = $xmlObj->roottag->tags[0]->tags[3]->cdata;
	$nrdolote = $xmlObj->roottag->tags[0]->tags[4]->cdata;
	$dtemissa = $xmlObj->roottag->tags[0]->tags[5]->cdata;
	$dtlibera = $xmlObj->roottag->tags[0]->tags[6]->cdata;
	$dsocorre = $xmlObj->roottag->tags[0]->tags[7]->cdata;
}

?>
<form id="frmDetalheCheque" name="frmDetalheCheque" class="formulario" >

	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
	
	<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
	
	<br/>

	<fieldset>
		<legend align="left">Cheque</legend>
		
		<label for="cddbanco">Banco:</label>
		<input type="text" id="cddbanco" name="cddbanco" value="<?php echo $cddbanco ?>"/>

		<label for="cdagectl">Ag&ecirc;ncia:</label>
		<input type="text" id="cdagectl" name="cdagectl" value="<?php echo $cdagectl ?>"/>
		
		<label for="nrctachq">Conta:</label>
		<input type="text" id="nrctachq" name="nrctachq" value="<?php echo $nrctachq ?>"/>

		<label for="nrcheque">Cheque:</label>
		<input type="text" id="nrcheque" name="nrcheque" value="<?php echo $nrcheque ?>"/>
		
		<br/>
		
		<label for="dsdocmc7">CMC-7:</label>
		<input type="text" id="dsdocmc7" name="dsdocmc7" value="<?php echo '<'. mascara($dsdocmc7, '########<##########>############:') ?>"/>
		
	</fieldset>
	
	<fieldset>
	
		<legend align="left">Emitente</legend>
		
		<label for="nrcpfcgc">CPF/CNPJ:</label>
		<input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo $nrcpfcgc ?>"/>

		<label for="dsemiten">Emitente:</label>
		<input type="text" id="dsemiten" name="dsemiten" value="<?php echo $dsemiten ?>"/>
		
	</fieldset>

	<fieldset>
		<legend align="left">Lote</legend>
		
		<label for="dtmvtolt">Data Movimento:</label>
		<input type="text" id="dtmvtolt" name="dtmvtolt" value="<?php echo $dtmvtolt ?>"/>

		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo $cdagenci ?>"/>

		<label for="cdbccxlt">Banco/Caixa:</label>
		<input type="text" id="cdbccxlt" name="cdbccxlt" value="<?php echo $cdbccxlt ?>"/>

		<label for="nrdolote">Lote:</label>
		<input type="text" id="nrdolote" name="nrdolote" value="<?php echo $nrdolote ?>"/>

	</fieldset>
	
	<fieldset>
	
		<legend align="left">Ocorr&ecirc;ncia</legend>
		
		<label for="dsocorre">Ocorr&ecirc;ncia:</label>
		<input type="text" id="dsocorre" name="dsocorre" value="<?php echo $dsocorre ?>"/>
		
	</fieldset>
	
	<fieldset style="padding-top: 5px">
	
	<label for="dtemissa">Data de Emiss&atilde;o:</label>
	<input type="text" id="dtemissa" name="dtemissa" value="<?php echo $dtemissa ?>"/>

	<label for="dtlibera">Data Boa:</label>
	<input type="text" id="dtlibera" name="dtlibera" value="<?php echo $dtlibera ?>"/>

	<label for="vlcheque">Valor:</label>
	<input type="text" id="vlcheque" name="vlcheque" value="<?php echo $vlcheque ?>"/>
	
	</fieldset>
	
	<br style="clear:both" />	
	
</form>

<div id="divBotoesDetalhe" style="padding-bottom:10px;">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Voltar</a>
	<a href="#" class="botao" id="btAlterarChq" onclick="confirmaAlteraDetalhe(); return false;" style="display: none" >Alterar</a>
</div>