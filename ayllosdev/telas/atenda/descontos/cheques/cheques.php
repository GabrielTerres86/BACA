<?php 

	/***************************************************************************
	 Fonte: cheques.php
	 Autor: Guilherme
	 Data : Março/2009                 Última Alteração: 18/11/2011

	 Objetivo  : Mostrar opção cheques da Rotina de Desconto de Cheques

	 Alterações: 11/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
					
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
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

	setVarSession("nmrotina","DSC CHQS");
	
	include("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	
	// Monta o xml de requisição
	$xmlDesctoChq  = "";
	$xmlDesctoChq .= "<Root>";
	$xmlDesctoChq .= "	<Cabecalho>";
	$xmlDesctoChq .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlDesctoChq .= "		<Proc>busca_dados_dscchq</Proc>";
	$xmlDesctoChq .= "	</Cabecalho>";
	$xmlDesctoChq .= "	<Dados>";
	$xmlDesctoChq .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDesctoChq .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDesctoChq .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDesctoChq .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDesctoChq .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDesctoChq .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDesctoChq .= "		<idseqttl>1</idseqttl>";	
	$xmlDesctoChq .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDesctoChq .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDesctoChq .= "	</Dados>";
	$xmlDesctoChq .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDesctoChq);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDscChq = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDscChq->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDscChq->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDscChq->roottag->tags[0]->tags[0]->tags;
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<form id="frmCheques">
	<fieldset>
		<legend><? echo utf8ToHtml('Cheques') ?></legend>
		
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
		
		<label for="vlutiliz"><? echo utf8ToHtml('Valor utilizado:') ?></label>
		<input type="text" name="vlutiliz" id="vlutiliz" value="<?php echo number_format(str_replace(",",".",$dados[6]->cdata),2,",",".") . " (". $dados[7]->cdata; if ($dados[7]->cdata > 1) { echo " cheques)"; } else { echo " cheque)"; } ?>" />
		<br />
		
	</fieldset>
</form>
<div id="divBotoes" >
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(1,0,4,'DESCONTOS','DESCONTOS');return false;" />
	<input type="image" name="btnbordero" id="btnbordero" src="<?php echo $UrlImagens; ?>botoes/borderos.gif" <?php if (!in_array("DSC CHQS - BORDERO",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } else { echo 'onClick="carregaBorderosCheques();return false;"'; } ?> />
	<input type="image" name="btnlimite" id="btnlimite" src="<?php echo $UrlImagens; ?>botoes/limite.gif" <?php if (!in_array("DSC CHQS - LIMITE",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } else { echo 'onClick="carregaLimitesCheques();return false;"'; } ?> />
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao1","divConteudoOpcao");

// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE CHEQUES");

formataLayout('frmCheques');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
