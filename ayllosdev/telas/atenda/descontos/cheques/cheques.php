<?php 

	/***************************************************************************
	 Fonte: cheques.php
	 Autor: Guilherme
 	 Data : Março/2009                 Última Alteração: 26/06/2017

	 Objetivo  : Mostrar opção cheques da Rotina de Desconto de Cheques

	 Alterações: 11/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
					
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
			
				 06/09/2016 - Inclusao do botão "Renovação" para renovação do limite 
							  de desconto de cheque. Projeto 300. (Lombardi)
			
				 09/09/2016 - Inclusao do botão "Desbloquear Inclusao de Bordero" para desbloquear
							  inclusao de desconto de cheque. Projeto 300. (Lombardi)
				
                 26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).
				
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
	$executandoProdutos = $_POST['executandoProdutos'];
	$cdproduto = $_POST['cdproduto'];
	
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
		
		<input type="hidden" name="hd_perrenov" id="hd_perrenov" value="<?php echo $dados[9]->cdata; ?>" />
		<input type="hidden" name="hd_insitblq" id="hd_insitblq" value="<?php echo $dados[10]->cdata; ?>" />
		
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
		
		<label for="insitblq"><? echo utf8ToHtml('Inclus&atilde;o de Border&ocirc;:') ?></label>
		<input type="text" name="insitblq" id="insitblq" value="<?php echo $dados[10]->cdata == 1 ? "BLOQUEADA" : "LIBERADA"; ?>" />
		<br />
		
	</fieldset>
</form>
<div id="divBotoes" >
	
	<a href="#" class="botao" id="btnvoltar" name="btnvoltar" onClick="voltaDiv(1,0,4,'DESCONTOS','DESCONTOS');return false;">Voltar</a>
	<a href="#" class="botao" id="btnbordero" name="btnbordero"  <?php if (!in_array("DSC CHQS - BORDERO",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } else { echo 'onClick="carregaBorderosCheques();return false;"'; } ?>>Border&ocirc;s</a>
	<a href="#" class="botao" id="btnlimite" name="btnlimite" <?php if (!in_array("DSC CHQS - LIMITE",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } else { echo 'onClick="carregaLimitesCheques();return false;"'; } ?>>Limite</a>
	<a href="#" class="botao" id="btnrenovacao" name="btnrenovacao">Renova&ccedil;&atilde;o</a>
	<div style="height: 3px;"></div>
	<a href="#" class="botao" id="btndesinbord" style="display:none;" name="btndesinbord">Desbloquear Inclus&atilde;o de Border&ocirc;</a>
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

	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
	if (executandoProdutos == true) {
	
       //Bordero	
	  if (cdproduto == 34 ) {
		$('#btnbordero','#divBotoes').click();
		
	  //Limite
	  }else if (cdproduto == 36 ) {
		$('#btnlimite','#divBotoes').click();
	  }
	}

</script>
