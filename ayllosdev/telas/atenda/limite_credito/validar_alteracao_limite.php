<?php 

	/****************************************************************************
	     Fonte: validar_alteracao_limite.php                                
	      Autor: David                                                       
	      Data : Janeiro/2015                   �ltima Altera��o: 06/05/2014
	                                                                    
	      Objetivo  : Validar Alteracao Limite de Cr�dito - rotina
	                  de Limite de Cr�dito da tela ATENDA                 
	                                                                     
	      Altera��es:  Tirar a retirada da mensagem de aguardo (Gabriel-RKAM)                                              
    ***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) || 
	    !isset($_POST["nrctrlim"]) || 
		!isset($_POST["cddlinha"]) || 
	    !isset($_POST["vllimite"]) || 
		!isset($_POST["flgimpnp"]) || 
		!isset($_POST["inconfir"]) || 
		!isset($_POST["inconfi2"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$cddlinha = $_POST["cddlinha"];
	$vllimite = $_POST["vllimite"];
	$flgimpnp = $_POST["flgimpnp"];	
	$inconfir = $_POST["inconfir"];
	$inconfi2 = $_POST["inconfi2"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Verifica se n�mero da linha de cr�dito � um inteiro v�lido
	if (!validaInteiro($cddlinha)) {
		exibeErro("Linha de cr&eacute;dito inv&aacute;lida.");
	}
	
	// Verifica se valor do limite � um decimal v�lido
	if (!validaDecimal($vllimite)) {
		exibeErro("Valor do Limite de Cr&eacute;dito inv&aacute;lido.");
	}	
	
	// Valida impress�o de nota promiss�ria
	if ($flgimpnp <> "yes" && $flgimpnp <> "no") {
		exibeErro("Indicador de impress&atilde;o da nota promiss&oacute;ria inv&aacute;lido.");
	}
	
	// Verifica se indicador de confirma��o � um inteiro v�lido
	if (!validaInteiro($inconfir)) {
		exibeErro("Indicador de confirma&ccedil;&atilde;o inv&aacute;lido.");
	}	
	
	// Verifica se indicador de confirma��o � um inteiro v�lido
	if (!validaInteiro($inconfi2)) {
		exibeErro("Indicador de confirma&ccedil;&atilde;o inv&aacute;lido.");
	}
	

	// Monta o xml de requisi��o
	$xmlSetLimite  = "";
	$xmlSetLimite .= "<Root>";
	$xmlSetLimite .= "	<Cabecalho>";
	$xmlSetLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlSetLimite .= "		<Proc>validar-alteracao-limite</Proc>";
	$xmlSetLimite .= "	</Cabecalho>";
	$xmlSetLimite .= "	<Dados>";
	$xmlSetLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetLimite .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetLimite .= "		<idseqttl>1</idseqttl>";
	$xmlSetLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetLimite .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlSetLimite .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlSetLimite .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlSetLimite .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";	
	$xmlSetLimite .= "		<cddlinha>".$cddlinha."</cddlinha>";
	$xmlSetLimite .= "		<vllimite>".$vllimite."</vllimite>";
	$xmlSetLimite .= "		<flgimpnp>".$flgimpnp."</flgimpnp>";
	$xmlSetLimite .= "		<inconfi2>".$inconfi2."</inconfi2>";
	$xmlSetLimite .= "	</Dados>";
	$xmlSetLimite .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
			
		$mensagem = $xmlObjLimite->roottag->tags[1]->tags; 
		$dsmensag = $xmlObjLimite->roottag->tags[1]->tags[0]->tags[1]->cdata;
		$inconfir = $xmlObjLimite->roottag->tags[1]->tags[0]->tags[0]->cdata;	
		$grupo	  = $xmlObjLimite->roottag->tags[2]->tags;  	
			
		//Se a conta em quest�o excedeu o limite legal e fizer parte de algum grupo econ�mico ent�o, ser� mostrado todas as contas deste grupo.
		if($inconfir == 3 && count($grupo) > 0){
											
			echo "strHTML = '';";
			echo "strHTML2 = '';";
						
			echo "strHTML2 += '<form name=\'frmGrupoEconomico\' id=\'frmGrupoEconomico\' class=\'formulario\'>';";
			echo "strHTML2 +=	'<br />';";
			echo "strHTML2 +=	'Conta pertence a grupo econ&ocirc;mico.';";
			echo "strHTML2 +=	'<br />';";
			echo "strHTML2 +=	'Valor ultrapassa limite legal permitido.';";
			echo "strHTML2 +=	'<br />';";
			echo "strHTML2 +=	'Verifique endividamento total das contas.';";
			echo "strHTML2 += '</form>';";
			echo "strHTML  +='<br style=\'clear:both\' />';";
			echo "strHTML  +='<br style=\'clear:both\' />';";
			echo "strHTML  +='<div class=\'divRegistros\'>';";
			echo "strHTML  +=	'<table>';";
			echo "strHTML  +=		'<thead>';";
			echo "strHTML  +=			'<tr>';";
			echo 'strHTML  +=				\'<th>'.utf8ToHtml("Contas Relacionadas").'</th>\';';
			echo "strHTML  +=			'</tr>';";
			echo "strHTML  +=		'</thead>';";
			echo "strHTML  +=		'<tbody>';";
		
			for ($i = 0; $i < count($grupo); $i++) {
					
				echo "strHTML +=				'<tr>';";
				echo 'strHTML +=					\'<td><span>'.$grupo[$i]->tags[2]->cdata.'</span>\';';
				echo 'strHTML +=							\''.formataContaDV($grupo[$i]->tags[2]->cdata).'\';';
				echo "strHTML +=					'</td>';";
				echo "strHTML +=				'</tr>';";
						
			}
			
			echo "strHTML +=		'</tbody>';";
			echo "strHTML +=	'</table>';";
				
			$metodo = "blockBackground(parseInt($(\\'#divRotina\\').css(\\'z-index\\')));";
			echo 'dsmetodo = \'showError("error","'.$xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","'.$metodo.'"     );\';';
			
			echo 'hideMsgAguardo();';
			echo 'showError("inform","'.$dsmensag.'","Alerta - Aimaro","mostraMsgsGrupoEconomico();formataGrupoEconomico();");';
						
			exit();
			
		
		}elseif($inconfir == 3){ 
		
			echo 'hideMsgAguardo();';
			echo 'showError("inform","'.$dsmensag.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();showError(\'error\',\''.$xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata.'\',\'Alerta - Aimaro\',\'blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))\');");';
			exit();
			
		}else{
	
			exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
			
		}
		
	} 	
	
	$mensagem = $xmlObjLimite->roottag->tags[0]->tags; 
	$dsmensag = $xmlObjLimite->roottag->tags[0]->tags[0]->tags[1]->cdata;
	$inconfir = $xmlObjLimite->roottag->tags[0]->tags[0]->tags[0]->cdata;	
	
	$cddopcao = $_POST['cddopcao'];
	
	//bruno - prj 438 - sprint 7 - novo limite
	//echo "buscaDadosProposta('$nrdconta','$nrctrlim');";
	echo "trataObservacao('".$cddopcao."');";
	echo "trataGAROPC('".$cddopcao."','".$nrctrlim."');"; //cddopcao, nrctrlim
		
	// Mostra div com campos para dados de renda
	echo '$("#divDadosLimite").css("display","none");';
	// echo '$("#divDadosRenda").css("display","block");';	 
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
	// Fun��o para mostrar mensagem de confirma��o retornada pela BO
	function exibeConfirmacao($msgConfirmacao) {
		echo 'hideMsgAguardo();';
		echo 'showConfirmacao("'.$msgConfirmacao.'","Confirma&ccedil;&atilde;o - Aimaro","validarNovoLimite(aux_inconfir,aux_inconfi2)","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		exit();	
	}	
	
?>