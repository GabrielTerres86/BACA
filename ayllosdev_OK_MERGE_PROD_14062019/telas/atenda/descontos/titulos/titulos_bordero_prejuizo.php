<?php 

	/************************************************************************
	 Fonte: titulos_bordero_prejuizo.php                                        
	 Autor: Cassia de Oliveira (GFT)
	 Data : 24/08/2018                Última Alteração: 25/08/2018
	                                                                  
	 Objetivo  : Detalhes do prejuizo do borderô
	 Alterações: 
	 - 04/09/2018 - Alteração do saldo do prejuizo [Vitor Shimada Assanuma (GFT)]
	 - 11/09/2018 - Reformulação dos campos [Vitor Shimada Assanuma (GFT)]
	
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'D',false)) <> '') {
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
	
	// Carrega permissões do operador
	include("../../../../includes/carrega_permissoes.php");	

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


	$tosdprej = converteFloat($dados->tosdprej->cdata);
	$tottjmpr = converteFloat($dados->tottjmpr->cdata);
	$topgjmpr = converteFloat($dados->topgjmpr->cdata);

	$totjur60 = converteFloat($dados->totjur60->cdata);
	$totpgm60 = converteFloat($dados->totpgm60->cdata);

	$totjur60 = $totjur60 - $totpgm60;
	$tosdprej = formataMoeda($tosdprej + ($tottjmpr - $topgjmpr) - $totjur60);

	$vlsldatu = formataMoeda(converteFloat($dados->vlsldatu) + converteFloat($dados->vlsldaco));
?>

<form id="formDetalhePrejuizo">
	<fieldset>
		<legend><? echo utf8ToHtml('Prejuizo do Borderô: ').$nrborder ?></legend>
		
		<label for="dtprejuz"><? echo utf8ToHtml('Transferido em:') ?></label>
		<input type="text" name="dtprejuz" id="dtprejuz" value="<?=$dados->dtprejuz?>" />

		<label for="vlaboprj"><? echo utf8ToHtml('Valor abono:') ?></label>
	    <input type="text" name="vlaboprj" id="vlaboprj" value="<?=$dados->vlaboprj?>" />
	    <br /> 

		<label for="toprejuz"><? echo utf8ToHtml('Prejuízo original:') ?></label>
		<input type="text" name="toprejuz" id="toprejuz" value="<?= $dados->toprejuz ?>" />
		<br />

		<label for="tojrmprj"><? echo utf8ToHtml('Juros do mês:') ?></label>
	    <input type="text" name="tojrmprj" id="tojrmprj" value="<?=$dados->tojrmprj?>" />
		<br />

		<label for="tosdprej"><? echo utf8ToHtml('Saldo prejuízo original:') ?></label>
		<input type="text" name="tosdprej" id="tosdprej" value="<?=$tosdprej?>" />
		<br />

		<label for="tovlpago"><? echo utf8ToHtml('Valores pagos') ?></label>
		<input type="text" name="tovlpago" id="tovlpago" value="<?=$dados->tovlpago ?>" /> 
		<br />

		<label for="tojraprj"><? echo utf8ToHtml('Juros acumulados:') ?></label>
		<input type="text" name="tojraprj" id="tojraprj" value="<?=$dados->tojraprj?>" />
		<br />

		<label for="topgjrpr"><? echo utf8ToHtml('Vl.Pago Jur.Acumulados:') ?></label>
		<input type="text" name="topgjrpr" id="topgjrpr" value="<?=$dados->topgjrpr?>" />
		<br />

		<label for="tottmupr"><? echo utf8ToHtml('Multa:') ?></label>
		<input type="text" name="tottmupr" id="tottmupr" value="<?=$dados->tottmupr?>" />
		<br />

		<label for="topgmupr"><? echo utf8ToHtml('Vl. pago de multa:') ?></label>
		<input type="text" name="topgmupr" id="topgmupr" value="<?=$dados->topgmupr ?>" /> 
		<br />

		<label for="tottjmpr"><? echo utf8ToHtml('Juros de mora:') ?></label>
		<input type="text" name="tottjmpr" id="tottjmpr" value="<?=$dados->totjur60?>" />
		<br />

		<label for="topgjmpr"><? echo utf8ToHtml('Vl.Pago de mora:') ?></label>
		<input type="text" name="topgjmpr" id="topgjmpr" value="<?=$dados->totpgm60?>" />
		<br />

		<label for="toiofprj"><? echo utf8ToHtml('Valor de IOF:') ?></label>
		<input type="text" name="toiofprj" id="toiofprj" value="<?=$dados->toiofprj?>" />
		<br />

		<label for="toiofppr"><? echo utf8ToHtml('Vl.Pago de IOF:') ?></label>
		<input type="text" name="toiofppr" id="toiofppr" value="<?=$dados->toiofppr?>" />
		<br />
	
		<label for="diasatrs"><? echo utf8ToHtml('Dias em atraso:') ?></label>
		<input type="text" name="diasatrs" id="diasatrs" value="<?=$dados->diasatrs ?>" />
		<br />

		<label for="vlsldatu"><? echo utf8ToHtml('Saldo atualizado:') ?></label>
		<input type="text" name="vlsldatu" id="vlsldatu" value="<?=$vlsldatu?>" />
		<br />

	</fieldset>
</form><!-- formDetalhePrejuizo -->


<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<a href="#" class="botao"  name="btnvoltar"   id="btnvoltar"   onClick="voltaDiv(4,3,4,'CONSULTA DE BORDER&Ocirc;');return false;" > Voltar</a>
</div>

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao5");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - DETALHES");

	formataLayout('formDetalhePrejuizo');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

</script>