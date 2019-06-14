<?php 

	/*********************************************************************************
	 Fonte: aplicacao_verifica_tipo.php                               
	 Autor: David                                                     
	 Data : Outubro/2010                 Última Alteração: 25/07/2014 
	                                                                  
	 Objetivo  : Verificar tipo (RDCPRE/RDCPOS) da nova aplicação     	
	                                                                  	 
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p   
	                          para a BO b1wgen0081.p (Adriano).       
	            													   
	             11/06/2014 - Ajuste referente ao projeto de captação 
							  (Adriano) 							   
	             	
				 25/07/2014 - Implementacao de novas verificacoes de tipos de produto
							  para projeto de captação (Jean Michel)	
	*********************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpaplica"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];	
	$tpaplica = $_POST["tpaplica"];	/*Codigo do tipo da aplicacao*/	
	$idtippro = $_POST["idtippro"];	/*Verifica se produto é PRE OU POS dos produtos novos*/
	$idprodut = $_POST["idprodut"];	/*Verifica se é produto novo ou antigo*/
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se tipo da aplicação é um inteiro válido
	if (!validaInteiro($tpaplica)) {
		exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
		
	if($idprodut == "A"){ //Produtos Antigos
		// Monta o xml de requisição
		$xmlAplicacao  = "";
		$xmlAplicacao .= "<Root>";
		$xmlAplicacao .= "	<Cabecalho>";
		$xmlAplicacao .= "		<Bo>b1wgen0081.p</Bo>";
		$xmlAplicacao .= "		<Proc>validar-tipo-aplicacao</Proc>";
		$xmlAplicacao .= "	</Cabecalho>";
		$xmlAplicacao .= "	<Dados>";
		$xmlAplicacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlAplicacao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlAplicacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlAplicacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlAplicacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlAplicacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlAplicacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlAplicacao .= "		<idseqttl>1</idseqttl>";
		$xmlAplicacao .= "		<tpaplica>".$tpaplica."</tpaplica>";						
		$xmlAplicacao .= "	</Dados>";
		$xmlAplicacao .= "</Root>";	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlAplicacao);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjAplicacao = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjAplicacao->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjAplicacao->roottag->tags[0]->tags[0]->tags[4]->cdata);
		} 
		
		echo 'tpaplrdc = '.$xmlObjAplicacao->roottag->tags[0]->attributes["TPAPLRDC"].';';
		echo 'tpaplica = '.$tpaplica.';'; /*Codigo do tipo da aplicacao*/	
		echo 'idtippro = '.$idtippro.';'; /*Verifica se produto é PRE OU POS dos produtos novos*/
		echo 'idprodut = "'.$idprodut.'";'; /*Verifica se é produto novo ou antigo*/
?>
	
		$("#divSelecionaCarencia").hide();
		
		if (tpaplrdc == 1) { // RDCPRE
			$("#qtdiacar","#frmDadosAplicacaoPre").val("0");
			$("#btnLupaCarencia").css("cursor","default");
			$("#btnLupaCarencia").unbind("click");
			$("#btnLupaCarencia").bind("click",function() {
			
				return false;
			});
		} else {
			$("#btnLupaCarencia").css("cursor","pointer");
			$("#btnLupaCarencia").unbind("click");
			$("#btnLupaCarencia").bind("click",function() {
				$("#dtresgat","#frmDadosAplicacaoPos").focus();
				carregaCarenciaAplicacao();
				return false;
			});
		}
		
		// Esconde mensagem de aguardo
		hideMsgAguardo();
		
		// Bloqueia conteúdo que está átras do div da rotina
		blockBackground(parseInt($("#divRotina").css("z-index")));
			
		flgcaren = false;
		
		if (fnc != undefined) { 		
			eval(fnc); 
		}
	
<?php

	}else{ //Produtos Novos
		
?>		
		$("#divSelecionaCarencia").hide();
		
		tpaplrdc = 0;
		$("#btnLupaCarencia").css("cursor","pointer");
		$("#btnLupaCarencia").unbind("click");
		$("#btnLupaCarencia").bind("click",function() {	
			$("#flgrecno","#frmDadosAplicacaoPos").focus();
			carregaCarenciaAplicacao();
			return false;
		});
		
		// Esconde mensagem de aguardo
		hideMsgAguardo();
			
		// Bloqueia conteúdo que está átras do div da rotina
		blockBackground(parseInt($("#divRotina").css("z-index")));
			
		flgcaren = false;
		
		if (fnc != undefined) { 		
			eval(fnc); 
		}
			
<?php
	}	

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","$(\'#tpaplica\',\'#frmDadosAplicacao\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
?>