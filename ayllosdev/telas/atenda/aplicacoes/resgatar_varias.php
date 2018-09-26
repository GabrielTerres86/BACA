<?php 

	/**************************************************************************
	 Fonte: resgatar_varias.php
	 Autor: Fabricio                                                 
	 Data : Agosto/2011                 Última alteração: 08/12/2014
	                                                                   
	 Objetivo  : Acessar op&ccedil;&atilde;o Resgatar Varias da Rotina 
	   		     de Aplicações da tela ATENDA             
	                                                                    
	 Alterações: 30/04/2014 - Ajuste referente ao projeto Captação:
							  - Layout dos botões
							  - Altura do divConteudoOpcao							  
						      (Adriano).

   			     12/08/2014 - Adicionar o valor padrão para o campo Data de 
				              Resgate (Douglas - Projeto Captação Internet 2014/2)
							  
				 08/12/2014 - Ajuste de flags de resgate manual e automatico (Jean Michel).
			                                					         
				 27/07/2016 - Corrigi a recuperacao de dados do post e do retorno XML. SD 479874 (Carlos R.)
			                                					         
				 17/04/2018 - Incluida verificacao de adesao do produto pelo 
                              tipo de conta. PRJ366 (Lombardi)
			                                					         
	**************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variaveis globais de controle, e biblioteca de funcoes	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parametros necessarios nao foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["flcadrgt"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
		
	$nrdconta = $_POST["nrdconta"];
	$flcadrgt = $_POST["flcadrgt"];
	$flgauto  = ( isset($_POST["flgauto"]) ) ? $_POST["flgauto"] : '';
	
	// Verifica se numero da conta e um inteiro valido
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
	
	// Verifica se flag de opcao resgate e valida
	if ($flcadrgt <> "yes" && $flcadrgt <> "no") {
		exibeErro("Identificador de resgate inv&aacute;lido.");
	}
	
	if ($flcadrgt == "no") {
		
		// Aumenta tamanho do div onde o conteudo da opcao sera visualizado
		echo '$("#divConteudoOpcao").css("height","65px");';
	
		// Mostra div para opcao de resgate
		echo '$("#divAplicacoesPrincipal").css("display","none");';	
		echo '$("#divResgatarVarias").css("display","block");';
		
		// Zerar variaveis globais utilizadas na opcao
		echo 'dtresgat = "";';
		echo 'nrdocmto = 0;';
		echo 'flgoprgt = false;';
		
	}else{
						
		$flgauto = ($flgauto == 'false') ? 0 : 1;
		
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Dados>";
		$xml .= "   <flagauto>".$flgauto."</flagauto>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <idseqttl>1</idseqttl>";
		$xml .= "   <nraplica>0</nraplica>";
		$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";		
		
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "ATENDA", "VALRESVAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);
				
		// Se ocorrer um erro, mostra critica
		if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){	
			$msgErro = ( isset($xmlObj->roottag->tags[0]->cdata) ) ? $xmlObj->roottag->tags[0]->cdata : null;
			
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			
			exibeErro($msgErro);			
			exit();
		}else{						
			// Procura indíce da opcao "@"
			$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
		
			if ($idPrincipal === false) {
				$idPrincipal = 0;
			}
			
			$sldtotrg = ( isset($xmlObj->roottag->tags[0]->tags[0]->cdata) ) ? $xmlObj->roottag->tags[0]->tags[0]->cdata : 0;
			
			if ($sldtotrg == 0)
				exibeErro("N&atilde;o h&aacute; saldo dispon&iacute;vel para resgate. Verifique a situa&ccedil;&atilde;o das aplica&ccedil;&otilde;es e se n&atilde;o h&aacute; resgate programado.");
			?>
			
			var strHTML = "";
			strHTML += '<form action="" method="post" name="frmResgateVarias" id="frmResgateVarias" class="formulario" onSubmit="return false;">';
			strHTML += '	<fieldset>';
			
			<?php
				if ($flgauto == 1){
					?> 
					strHTML += '	<legend>Resgate de Aplicações - Automática</legend>';
					<?php
				} else {
					?>
					strHTML += '	<legend>Resgate de Aplicações - Manual</legend>';
					<?php
				}
				?>
			strHTML += '		<label for="slresgat">Saldo Total p/ Resgate:</label>';
			strHTML += '		<input name="slresgat" type="text" id="slresgat" value="<?php echo number_format(str_replace(",",".",$sldtotrg),2,",",".") ?>">';
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
			strHTML += '	<a href="#" class="botao" id="btVoltar" onClick="voltarDivResgatarVarias();return false;" >Voltar</a>';
									
			<?php 
			if ($flgauto == 1) { 
			?>
				strHTML += '	<a href="#" class="botao" id="btProsseguir" onClick="validaValorProdutoResgate(\'listarResgatesAuto(<?php echo dataParaTimestamp($glbvars["dtmvtolt"]); ?>);\',\'vlresgat\',\'frmResgateVarias\');return false;" >Prosseguir</a>';
									
			<?php 
			} else {
			?>
				strHTML += '	<a href="#" class="botao" id="btProsseguir" onClick="validaValorProdutoResgate(\'listarResgatesManual(<?php echo dataParaTimestamp($glbvars["dtmvtolt"]); ?>);\',\'vlresgat\',\'frmResgateVarias\');return false;" >Prosseguir</a>';
									
			<?php
			}
			?>
				
			strHTML += '</div>';
			
			$("#divOpcoes").html(strHTML);
			formataResgatarVarias();
			$("#slresgat","#frmResgateVarias").setMask("DECIMAL","zzz.zzz.zz9,99","","");
			$("#slresgat","#frmResgateVarias").prop("disabled",true);
			$("#slresgat","#frmResgateVarias").attr("class","campoTelaSemBorda");
			$("#vlresgat","#frmResgateVarias").setMask("DECIMAL","zzz.zzz.zz9,99","","");
			$("#dtresgat","#frmResgateVarias").setMask("DATE","","","divRotina");			
			$("#divResgatarVarias").css("display","none");
			$("#divOpcoes").css("display","block");
			
			<?php	
		}		
	}
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
		
	// Funcao para exibir erros na tela atraves de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>