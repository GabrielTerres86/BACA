<? 
/*!
 * FONTE        : form_detalhes.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 30/03/2015
 * OBJETIVO     : Tela para consultar detalhes da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 
 */
 	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");	
	require_once("../../class/xmlfile.php");
	isPostMethod();	

	$dsorigem = $_POST["dsorigem"];
	$nrdconta = $_POST["nrdconta"];
	$nrctremp = $_POST["nrctremp"];
	$flgjudic = $_POST["flgjudic"];
	$flextjud = $_POST["flextjud"];
	$flgehvip = $_POST["flgehvip"];
	$dtenvcbr = $_POST["dtenvcbr"];
	$dtinclus = $_POST["dtinclus"];
	$cdopeinc = $_POST["cdopeinc"];
	$dtaltera = $_POST["dtaltera"];
	$cdoperad = $_POST["cdoperad"];
	$assessor = $_POST["assessor"];
	$motivocin = $_POST["motivocin"];
	
	$nrborder = $_POST["nrborder"];
	$nrtitulo = $_POST["nrtitulo"];
	$nrdocmto = $_POST["nrdocmto"];
	
?>

<form id="frmDetalhes" name="frmDetalhes" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml("Detalhes"); ?></legend>

	<label for="dsorigem"><? echo utf8ToHtml("Origem:") ?></label>	
	<input name="dsorigem" id="dsorigem" type="text" maxlength="30" value="<? echo $dsorigem; ?>" />
	<br />
		
	<label for="nrdconta"><? echo utf8ToHtml("Conta:") ?></label>
	<input name="nrdconta" id="nrdconta" type="text" value="<? echo $nrdconta; ?>" />
	<br />
	
	<label for="nrctremp"><? echo utf8ToHtml("Contrato:") ?></label>
	<input name="nrctremp" id="nrctremp" type="text" value="<? echo $nrctremp; ?>" />
	<br />
	
	<label for="flgjudic"><? echo utf8ToHtml("Judicial:") ?></label>	
	<input name="flgjudic" id="flgjudic" type="text" maxlength="30" value="<? echo $flgjudic; ?>" />
	<br />
		
	<label for="flextjud"><? echo utf8ToHtml("Extra Judicial:") ?></label>
	<input name="flextjud" id="flextjud" type="text" value="<? echo $flextjud; ?>" />
	<br />
	
	<label for="flgehvip"><? echo utf8ToHtml("CIN:") ?></label>
	<input name="flgehvip" id="flgehvip" type="text" value="<? echo $flgehvip; ?>" />
	<br />
	
	
	<label for="dsmotcin"><? echo utf8ToHtml("Motivo CIN:") ?></label>
	<input name="dsmotcin" id="dsmotcin" type="text" value="<? echo $motivocin; ?>" />
	<br />

	<label for="nrborder"><? echo utf8ToHtml("Borderô:") ?></label>
	<input name="nrborder" id="nrborder" type="text" value="<? echo $nrborder; ?>" />
	<br />

	<label for="nrtitulo"><? echo utf8ToHtml("Título:") ?></label>
	<input name="nrtitulo" id="nrtitulo" type="text" value="<? echo $nrdocmto; ?>" />
	<br />
	
	<label for="dsassess"><? echo utf8ToHtml("Assessoria:") ?></label>
	<input name="dsassess" id="dsassess" type="text" value="<? echo $assessor; ?>" />
	<br />
	
	<label for="dtenvcbr"><? echo utf8ToHtml("Data Assessoria Cobrança:") ?></label>
	<input name="dtenvcbr" id="dtenvcbr" type="text" value="<? echo $dtenvcbr; ?>" />
	<br />
	
	<label for="dtinclus"><? echo utf8ToHtml("Data de inclusão:") ?></label>
	<input name="dtinclus" id="dtinclus" type="text" value="<? echo $dtinclus; ?>" />
	<br />
	
	<label for="cdopeinc"><? echo utf8ToHtml("Operador inclusão:") ?></label>
	<input name="cdopeinc" id="cdopeinc" type="text" value="<? echo $cdopeinc; ?>" />
	<br />
	
	<label for="dtaltera"><? echo utf8ToHtml("Data de alteração:") ?></label>
	<input name="dtaltera" id="dtaltera" type="text" value="<? echo $dtaltera; ?>" />
	<br />
	
	<label for="cdoperad"><? echo utf8ToHtml("Operador alteração:") ?></label>
	<input name="cdoperad" id="cdoperad" type="text" value="<? echo $cdoperad; ?>" />
	<br />
	
	</fieldset>	

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
</div>

<script> 
			
	$(document).ready(function(){
		formataDetalhes();
	});

</script>