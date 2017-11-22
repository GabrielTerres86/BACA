<?php 

	/***************************************************************************
	 Fonte: titulos.php
	 Autor: Guilherme
	 Data : Novembro/2008                 Última Alteração: 09/07/2012

	 Objetivo  : Mostrar opção Títulos da Rotina de Desconto de Títulos

	 Alterações: 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				 
				 09/07/2012 - Inclusão de campos no form para listagem de 
                              informações de títulos descontados com e sem
                              registro (Lucas).
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS");
	
	include("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se os parêmetros necessários foram informados
	if (!isset($_POST["nrdconta"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	
	// Monta o xml de requisição
	$xmlDesctoTit  = "";
	$xmlDesctoTit .= "<Root>";
	$xmlDesctoTit .= "	<Cabecalho>";
	$xmlDesctoTit .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlDesctoTit .= "		<Proc>busca_dados_dsctit</Proc>";
	$xmlDesctoTit .= "	</Cabecalho>";
	$xmlDesctoTit .= "	<Dados>";
	$xmlDesctoTit .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDesctoTit .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDesctoTit .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDesctoTit .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDesctoTit .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDesctoTit .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDesctoTit .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDesctoTit .= "	</Dados>";
	$xmlDesctoTit .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDesctoTit);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDscTit = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDscTit->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDscTit->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDscTit->roottag->tags[0]->tags[0]->tags;
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	//$xmlObjLiberacao->roottag->tags[1]->attributes["INDENTRA"]
?>

<form id="frmTitulos">
	<fieldset>
		<legend><? echo utf8ToHtml('Títulos') ?></legend>
		
		<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>
		<input type="text" name="nrctrlim" id="nrctrlim" value="<?php echo formataNumericos('zzz.zzz.zz9',$dados[0]->cdata,'.'); ?>" />
		
		<label for="dtinivig"><? echo utf8ToHtml('Início:') ?></label>
		<input type="text" name="dtinivig" id="dtinivig" value="<?php echo $dados[1]->cdata; ?>" />
		
		<label for="qtdiavig"><? echo utf8ToHtml('Vigência:') ?></label>
		<input type="text" name="qtdiavig" id="qtdiavig" value="<?php echo $dados[2]->cdata; if ($dados[2]->cdata > 1) { echo " dias"; } else { echo " dia"; } ?>" />
		<br />
		
		<label for="vllimite"><? echo utf8ToHtml('Limite:') ?></label>
		<input type="text" name="vllimite" id="vllimite" value="<?php echo number_format(str_replace(",",".",$dados[3]->cdata),2,",","."); ?>" />
		
		<label for="qtrenova"><? echo utf8ToHtml('Renovado por:') ?></label>
		<input type="text" name="qtrenova" id="qtrenova" value="<?php echo $dados[4]->cdata; if ($dados[4]->cdata > 1) { echo " vezes"; } else { echo " vez"; } ?>" />
		<br />
		
		<label for="dsdlinha"><? echo utf8ToHtml('Linha de descontos:') ?></label>
		<input type="text" name="dsdlinha" id="dsdlinha" value="<?php echo $dados[5]->cdata; ?>" />
		<br />
		
		<label for="vlutilcr"><? echo utf8ToHtml('Valor utilizado (Registrada):') ?></label>
		<input type="text" name="vlutilcr" id="vlutilcr" value="<?php echo number_format(str_replace(",",".",$dados[10]->cdata),2,",",".") . " (". $dados[9]->cdata; if ($dados[9]->cdata > 1) { echo " t&iacute;tulos)"; } else { echo " t&iacute;tulos)"; } ?>" />
		<br />
		
		<label for="vlutilsr"><? echo utf8ToHtml('Valor utilizado (Sem Registro):') ?></label>
		<input type="text" name="vlutilsr" id="vlutilsr" value="<?php echo number_format(str_replace(",",".",$dados[12]->cdata),2,",",".") . " (". $dados[11]->cdata; if ($dados[11]->cdata > 1) { echo " t&iacute;tulos)"; } else { echo " t&iacute;tulos)"; } ?>" />
		<br />
		
		
	</fieldset>
</form>
<div id="divBotoes" >
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(1,0,4,'DESCONTOS','DESCONTOS');return false;" />
	<input type="image" name="btnbordero" id="btnbordero" src="<?php echo $UrlImagens; ?>botoes/borderos.gif" <?php if (!in_array("DSC TITS - BORDERO",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } else { echo 'onClick="carregaBorderosTitulos();return false;"'; } ?> />
	<input type="image" name="btnlimite" id="btnlimite" src="<?php echo $UrlImagens; ?>botoes/limite.gif" <?php if (!in_array("DSC TITS - LIMITE",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } else { echo 'onClick="carregaLimitesTitulos();return false;"'; } ?> />
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao1","divConteudoOpcao");

// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS");

formataLayout('frmTitulos');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
