<?php 

	/************************************************************************
	 Fonte: titulos_bordero_visualizar_detalhes.php                                        
	 Autor: Vitor Shimada Assanuma (GFT)
	 Data : 13/08/2018                Última Alteração: 14/08/2018
	                                                                  
	 Objetivo  : Detalhes do título do borderô
	 Alterações: 
	  - 08/10/2018 - Alteração da permissão da tela para verificar o Consultar e não uma própria (Vitor S Assanuma - GFT)
	
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
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

	// Verifica se o número da conta foi informado
	if (!isset($_POST["selecionados"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	// Pega as infos vindos do POST
	$selecionados   = $_POST["selecionados"];
	$nrdconta       = $_POST["nrdconta"];
	$nrborder       = $_POST["nrborder"];
	$arrSelecionado = explode(";", $selecionados);

	// Cria XML para mensageria
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta.    "</nrdconta>";
    $xml .= "   <nrborder>".$nrborder.    "</nrborder>";
    $xml .= "   <chave>   ".$selecionados."</chave>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","BUSCA_DADOS_TITULO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    if ($root->erro){
		exibeErro($root->erro->registro->dscritic);
    }
    $dados = $root->dados;

    // Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<form id="formDetalheTitulo">
	<fieldset>
		<legend><? echo utf8ToHtml('Detalhes do Título: ').$arrSelecionado[3] ?></legend>
		
		<label for="nrborder"><? echo utf8ToHtml('Borderô:') ?></label>
		<input type="text" name="nrborder" id="nrborder" value="<?php echo formataNumericos('z.zzz.zz9',$nrborder,'.'); ?>" />

		<label for="dtdvenct"><? echo utf8ToHtml('Vencimento:') ?></label>
		<input type="text" name="dtdvenct" id="dtdvenct" value="<?= $dados->dtvencto ?>" />
		<br />

		<label for="nrnosnum"><? echo utf8ToHtml('Nosso nº:') ?></label>
		<input type="text" name="nrnosnum" id="nrnosnum" value="<?php echo formataNumericos('z.zzz.zz9',$dados->nossonum,'.'); ?>" />

		<label for="vltitulo"><? echo utf8ToHtml('Valor Título:') ?></label>
		<input type="text" name="vltitulo" id="vltitulo" value="<?=$dados->vltitulo ?>" />
		<br />

		<label for="qtdprazo"><? echo utf8ToHtml('Prazo:') ?></label>
	    <input type="text" name="qtdprazo" id="qtdprazo" value="<?=$dados->diasprz?>" />

		<label for="diasdatr"><? echo utf8ToHtml('Dias de Atraso:') ?></label>
	    <input type="text" name="diasdatr" id="diasdatr" value="<?=$dados->diasatr?>" />
		<br />

		<label for="vlrmulta"><? echo utf8ToHtml('Multa:') ?></label>
		<input type="text" name="vlrmulta" id="vlrmulta" value="<?=$dados->vlmulta?>" />

		<label for="vljrmora"><? echo utf8ToHtml('Juros de Mora:') ?></label>
		<input type="text" name="vljrmora" id="vljrmora" value="<?=$dados->vlmora?>" />
		<br />

		<label for="vliofatr"><? echo utf8ToHtml('IOF Atraso:') ?></label>
		<input type="text" name="vliofatr" id="vliofatr" value="<?=$dados->vliof?>" />

		<label for="vlorpago"><? echo utf8ToHtml('Valor Pago:') ?></label>
		<input type="text" name="vlorpago" id="vlorpago" value="<?=$dados->vlpago?>" />
		<br />

		<label for="vlslddvd"><? echo utf8ToHtml('Saldo Devedor:') ?></label>
		<input type="text" name="vlslddvd" id="vlslddvd" value="<?=$dados->vlpagar?>" />

		<label for="nrctrcyb"><? echo utf8ToHtml('Nº Contrato Cyber:') ?></label>
		<input type="text" name="nrctrcyb" id="nrctrcyb" value="<?php echo formataNumericos('z.zzz.zz9',$dados->nrctrdsc,'.'); ?>" />
		<br />

		<label for="nmdpagad"><? echo utf8ToHtml('Nome do Pagador:') ?></label>
		<input type="text" name="nmdpagad" id="nmdpagad" value="<?=$dados->nmdsacad ?>" />
		<br />

		<label for="nrcpfcnp"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
		<input type="text" name="nrcpfcnp" id="nrcpfcnp" value="<?php echo formatar($dados->nrinssac, $dados->cdtpinsc->cdata == 1 ? 'cpf' : 'cnpj'); ?>" />
	</fieldset>
</form><!-- formDetalheTitulo -->


<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(5,4,5,'DESCONTO DE T&Iacute;TULOS - BORDEROS');return false; " />

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao5","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - DETALHES");

	formataLayout('formDetalheTitulo');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

</script>