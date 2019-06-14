<?php 

	/************************************************************************
	 Fonte: alterar.php
	 Autor: Guilherme
	 Data : Marco/2008                    �ltima Altera��o: 05/11/2010

	 Objetivo  : Mostrar op��o Alterar da rotina de Cart�es de Cr�dito da 
	             tela ATENDA

	 Altera��es: 23/04/2009 - Acerto no acesso a op��o utilizando nova 
	                          procedure para valida��o (David).
							  
	             05/11/2010 - Adapta��o Cart�o PJ (David).		
							  
	             05/07/2011 - Alterado para layout padr�o (Gabriel - DB1).
	************************************************************************/
	 
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
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
	$xmlSetCartao .= "		<Proc>verifica_acesso_alterar</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$flgadmbb = $xmlObjCartao->roottag->tags[0]->attributes["FLGADMBB"];	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	

?>

<div id="divBotoes">
	<form class="formulario">
		<fieldset>
			<legend style="margin-bottom: 5px">Alterar <?php if ($flgadmbb == "yes") { echo "Limites"; } else { echo "Limite"; } ?> ou Data de Vencimento</legend>

			<?php if ($flgadmbb == "yes") { // Cart�o BB ?>
			
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;" />
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/limite_debito.gif" onClick="alteraLimiteDebito();return false;" />
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/limite_credito.gif" onClick="alteraLimiteCredito();return false;" />
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/data_vencimento.gif" onClick="alteraDtVencimento(false);return false;" />
			
			<?php } else { // Cecred Visa ?>
				
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;" />
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/limite_credito.gif" onClick="alteraLimiteCredito();return false;" />
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/data_vencimento.gif" onClick="alteraDtVencimento(false);return false;" />
			
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