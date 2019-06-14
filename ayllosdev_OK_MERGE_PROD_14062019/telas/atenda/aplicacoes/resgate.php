<?php 

	/************************************************************************
	 Fonte: resgate.php                                               
	 Autor: David                                                     
	 Data : Outubro/2009                 		Última alteração: 03/12/2014
	                                                                  
	 Objetivo  : Acessar operação Resgate da Rotina de 
	             Aplicações da tela ATENDA                                          
	                                                                  
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p  
	                          para a BO b1wgen0081.p (Adriano).      
							  
			    30/04/2014 - Ajuste referente ao projeto Captação:
							  - Layout dos botões
							  - Altura do divConteudoOpcao
						      (Adriano).

   			     12/08/2014 - Adicionar o valor padrão para o campo Data de 
				              Resgate (Douglas - Projeto Captação Internet 2014/2)

				 03/12/2014 - Incluido verificacao de novos produtos de captacao
				              (Jean Michel).
							  
				 17/04/2018 - Incluida verificacao de adesao do produto pelo tipo de conta. PRJ366 (Lombardi)
				 
				 09/05/2018 - Permitir o resgate de aplicações bloqueadas (SM404)
							  
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["flcadrgt"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];	
	$flcadrgt = $_POST["flcadrgt"];	
	$tpaplica = $_POST["tpaplica"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".   41    ."</cdprodut>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}
	
	// Verifica se o n&uacute;mero da aplica&ccedil;&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nraplica)) {
		exibeErro("N&uacute;mero da aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Verifica se flag de op&ccedil;&atilde;o resgate &eacute; v&aacute;lida
	if ($flcadrgt <> "yes" && $flcadrgt <> "no") {
		exibeErro("Identificador de resgate inv&aacute;lido.");
	}
	
	if($tpaplica == "A") {
		
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlResgate  = "";
		$xmlResgate .= "<Root>";
		$xmlResgate .= "	<Cabecalho>";
		$xmlResgate .= "		<Bo>b1wgen0081.p</Bo>";
		$xmlResgate .= "		<Proc>valida-acesso-opcao-resgate</Proc>";
		$xmlResgate .= "	</Cabecalho>";
		$xmlResgate .= "	<Dados>";
		$xmlResgate .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlResgate .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlResgate .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlResgate .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlResgate .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlResgate .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlResgate .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlResgate .= "		<idseqttl>1</idseqttl>";
		$xmlResgate .= "		<nraplica>".$nraplica."</nraplica>";
		$xmlResgate .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
		$xmlResgate .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
		$xmlResgate .= "		<flcadrgt>".$flcadrgt."</flcadrgt>";
		$xmlResgate .= "	</Dados>";
		$xmlResgate .= "</Root>";	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlResgate);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjResgate = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjResgate->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjResgate->roottag->tags[0]->tags[0]->tags[4]->cdata);
		} 
	}
	
	if ($flcadrgt == "no") {
	
		// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
		echo '$("#divConteudoOpcao").css("height","60px");';
		
		// Mostra div para op&ccedil;&atilde;o de resgate
		echo '$("#divAplicacoesPrincipal").css("display","none");';	
		echo '$("#divResgate").css("display","block");';	
		
		// Zerar vari&aacute;veis globais utilizadas na op&ccedil;&atilde;o
		echo 'dtresgat = "";';
		echo 'nrdocmto = 0;';
		echo 'flgoprgt = false;';
		
	} else {
		?>
		var strHTML = "";
		strHTML += '<form action="" method="post" name="frmResgate" id="frmResgate" class="formulario" onSubmit="return false;">';
		strHTML += '	<fieldset>';
		strHTML += '	<legend>Resgate da Aplica&ccedil;&atilde;o</legend>';
		strHTML += '		<label for="tpresgat">Tipo de Resgate:</label>';
		strHTML += '		<select name="tpresgat" id="tpresgat">';
		strHTML += '			<option value="P" selected>PARCIAL</option>';
		strHTML += '			<option value="T">TOTAL</option>';
		strHTML += '		</select>';	
		strHTML += '		<br />';
		strHTML += '		<label for="vlresgat">Valor do Resgate:</label>';
		strHTML += '		<input name="vlresgat" type="text" id="vlresgat" autocomplete="no" value="0,00">';
		strHTML += '		<br />';
		strHTML += '		<label for="dtresgat">Data do Resgate:</label>';
		strHTML += '		<input name="dtresgat" type="text" id="dtresgat" autocomplete="no" value="<?php echo $glbvars["dtmvtolt"]?>">';
		strHTML += '		<br />';
		strHTML += '		<label for="flgctain">Resgatar Saldo para a CI?:</label>';
		strHTML += '		<select name="flgctain" id="flgctain">';
		strHTML += '			<option value="no">N&Atilde;O</option>';
		strHTML += '			<option value="yes">SIM</option>';
		strHTML += '		</select>';		
		strHTML += '		<br /><br />';
		strHTML += '		<label for="flautori">Autorizar opera&ccedil;&atilde;o:</label>';
		strHTML += '		<input type="checkbox" id="flautori" name="flautori" value="Bike">';
		strHTML += '	</fieldset>';

		strHTML += '	<div id="dvautoriza" name="dvautoriza">';
		strHTML += '	<fieldset>';
		strHTML += '	<legend>Autorizar Resgate da Aplica&ccedil;&atilde;o</legend>';
		strHTML += '		<br />';
		strHTML += '		<label for="cdopera2">Operador:</label>';
		strHTML += '		<input name="cdopera2" type="text" id="cdopera2" autocomplete="no">';
		strHTML += '		<br />';
		strHTML += '		<label for="cddsenha">Senha:</label>';
		strHTML += '		<input name="cddsenha" type="password" id="cddsenha" autocomplete="no">';	
		strHTML += '	</fieldset>';
		strHTML += '	</div>';		
		strHTML += '</form>';		
		strHTML += '<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">';
		strHTML += '	<a href="#" class="botao" id="btCancelar" onClick="voltarDivResgate();return false;" >Cancelar</a>';
		strHTML += '	<a href="#" class="botao" id="btConcluir" onClick="validaValorProdutoResgate(\'validaBloqueioAplicacao(1);\',\'vlresgat\',\'frmResgate\');return false;">Concluir</a>';
		strHTML += '</div>';
		
		$("#divOpcoes").html(strHTML);
		formataResgate();
		$("#vlresgat","#frmResgate").setMask("DECIMAL","zzz.zzz.zz9,99","","");
		$("#dtresgat","#frmResgate").setMask("DATE","","","divRotina");
		
		$("#tpresgat","#frmResgate").unbind("change");	  
		$("#tpresgat","#frmResgate").bind("change",function() {
			if ($(this).val() == "T") {
				$("#vlresgat","#frmResgate").val("0,00");
				$("#vlresgat","#frmResgate").prop("disabled",true);				
				$("#vlresgat","#frmResgate").attr("class","campoTelaSemBorda");
			} else {
				$("#vlresgat","#frmResgate").removeProp("disabled");
				$("#vlresgat","#frmResgate").attr("class","campo");				
			}
		});
		<?php
		if($tpaplica != "A") {
		?>
			$("#dtresgat","#frmResgate").habilitaCampo();
		<?php
		}else{
		?>
			$("#dtresgat","#frmResgate").desabilitaCampo();
		<?php
		}
		?>
		$("#divResgate").css("display","none");
		$("#divOpcoes").css("display","block");
		<?php				
	}
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>