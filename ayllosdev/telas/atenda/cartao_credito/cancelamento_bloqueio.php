<?php 

	/************************************************************************
	 Fonte: cancelamento_bloqueio.php
	 Autor: Guilherme
	 Data : Marco/2008                           �ltima Altera��o: 08/11/2010

	 Objetivo  : Mostrar op��o Canc/Blq da rotina de Cart�es de Cr�dito da 
			     tela ATENDA

	 Altera��es: 23/04/2009 - Acerto no acesso a op��o utilizando nova 
	                          procedure para valida��o (David).
							  
	             08/11/2010 - Adapta��o para cart�o PJ (David).
				 
				 06/07/2011 - Alterado para layout padr�o (Gabriel - DB1)

	             17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 

	*************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o c�digo do contrato do cart�o � um inteiro v�lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("C&oacute;digo do contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>verifica_acesso_cancblq</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$flgadmbb = $xmlObjCartao->roottag->tags[0]->attributes["FLGADMBB"];
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

?>

<div id="divBotoes">
	<form class="formulario">
		<fieldset>
			<legend style="margin-bottom: 5px"><?php if ($flgadmbb == "yes") { echo "Bloqueio"; } else { echo "Cancelamento"; } ?></legend>
			
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;" />
			<?php if ($flgadmbb == "yes") { // Cart�o BB ?>		
			
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/bloqueio.gif" onClick="tipoCancBlq(2);return false;" />
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/desbloqueio.gif" onClick="showConfirmacao('Deseja desbloquear o cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Ayllos','desfazCancBlqCartao(2)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" />
			
			<?php } else { // Cecred Visa ?>
			
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="tipoCancBlq(1);return false;" />
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/desfazer.gif" onClick="showConfirmacao('Deseja desfazer o cancelamento do cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Ayllos','desfazCancBlqCartao(1)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" />
			
			<?php } ?>
									
		</fieldset>
	</form>
	
	<br />
	
</div>

<script type="text/javascript">
// Mostra o div da Tela da op��o
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cart�es
$("#divConteudoCartoes").css("display","none");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� atr�s do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>