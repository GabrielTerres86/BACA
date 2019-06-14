<?php 

	/************************************************************************
	 Fonte: titulos_bordero_pagar_prejuizo.php                                       
	 Autor: Luis Fernando (GFT)                                                 
	 Data : Setembro/2018                Última Alteração: --/--/----
	                                                                  
	 Objetivo  : Fazer o pagamento dos borderos em prejuizo
	                                                                  	 
	 Alterações: 
	   - 20/09/2018 - Inserção do campo de Acordo (Vitor S. Assanuma - GFT)
	************************************************************************/
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS - BORDERO");

	// Valida permissão para a tela.
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"P")) <> "") {
		exibeErro($msgError);		
	}	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	// Verifica se o número do borderô
	if (!isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}		

	// Pega as infos vindos do POST
	$nrdconta       = $_POST["nrdconta"];
	$nrborder       = $_POST["nrborder"];

	// Cria XML para mensageria
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta.    "</nrdconta>";
    $xml .= "   <nrborder>".$nrborder.    "</nrborder>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    $xmlResult = mensageria($xml,"DSCT0003","BUSCA_DADOS_PREJUIZO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    if ($root->erro){
		exibeErro($root->erro->registro->dscritic);
    }
    $dados = $root->dados; 

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

	if (strlen($dados->dtliqprj->cdata)>0){
		exibeErro('Preju&Iacute;zo j&aacute; liquidado.');
	}

	$tosdprej = converteFloat($dados->tosdprej->cdata);
	$tottjmpr = converteFloat($dados->tottjmpr->cdata);
	$topgjmpr = converteFloat($dados->topgjmpr->cdata);
	$tottmupr = converteFloat($dados->tottmupr->cdata);
	$topgmupr = converteFloat($dados->topgmupr->cdata);
	$toiofprj = converteFloat($dados->toiofprj->cdata);
	$toiofppr = converteFloat($dados->toiofppr->cdata);
	$vlpagmto = converteFloat($dados->vlpagmto->cdata);
	$vlaboprj = converteFloat($dados->vlaboprj->cdata);
	$vlsldatu = converteFloat($dados->vlsldatu->cdata);
	$tojraprj = converteFloat($dados->tojraprj->cdata);
	$topgjrpr = converteFloat($dados->topgjrpr->cdata);
	$vlsldaco = converteFloat($dados->vlsldaco->cdata);
?>

<form id="formDetalhePrejuizoPagar">
	<fieldset>
		<legend><? echo utf8ToHtml('Prejuizo do Borderô: ').$nrborder ?></legend>
		
		<label for="tosdprej"><? echo utf8ToHtml('Saldo Devedor:') ?></label>
		<input type="text" name="tosdprej" id="tosdprej" value="<?=formataMoeda($tosdprej + ($tojraprj - $topgjrpr))?>" class="moeda campo" />

		<label for="vlsldaco"><? echo utf8ToHtml('Valor Acordo:') ?></label>
	    <input type="text" name="vlsldaco" id="vlsldaco" value="<?=formataMoeda($vlsldaco)?>"  class="moeda campo"/>
	    <br /> 

        <label for="vlsldjur"><? echo utf8ToHtml('Juros:') ?></label>
	    <input type="text" name="vlsldjur" id="vlsldjur" value="<?=formataMoeda($tottjmpr-$topgjmpr)?>"  class="moeda campo"/>
	    <br /> 

		<label for="vlsldmta"><? echo utf8ToHtml('Multa:') ?></label>
		<input type="text" name="vlsldmta" id="vlsldmta" value="<?=formataMoeda($tottmupr-$topgmupr)?>"  class="moeda campo"/>
		<br />

		<label for="vliofatr"><? echo utf8ToHtml('IOF Atraso:') ?></label>
		<input type="text" name="vliofatr" id="vliofatr" value="<?=formataMoeda($toiofprj-$toiofppr)?>"  class="moeda campo"/>
		<br />

		<label for="vlpagmto"><? echo utf8ToHtml('Pagamento:') ?></label>
	    <input type="text" name="vlpagmto" id="vlpagmto" value="<?=formataMoeda($vlpagmto)?>"  class="moeda campo"/>
		<br />

		<label for="vlaboprj"><? echo utf8ToHtml('Abono:') ?></label>
		<input type="text" name="vlaboprj" id="vlaboprj" value="<?=formataMoeda($vlaboprj)?>"  class="moeda campo"/>
		<br />

		<label for="vlsldprj"><? echo utf8ToHtml('Saldo:') ?></label>
		<input type="text" name="vlsldprj" id="vlsldprj" value="<?=formataMoeda($vlsldatu)?>"  class="moeda campo"/>

	</fieldset>
</form><!-- formDetalhePrejuizoPagar -->


<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<a href="#" class="botao"  name="btnvoltar"   id="btnvoltar"   onClick="voltaDiv(3,2,3,'CONSULTA DE BORDER&Ocirc;');return false;" > Voltar</a>
	<input type="button" class="botao" value="Continuar" onClick="pagarPrejuizo();"/>
</div>

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao1;divOpcoesDaOpcao2;");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - PAGAR PREJU&Iacute;ZO");

	formataLayout('formDetalhePrejuizoPagar');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

</script>