<?php 

	/************************************************************************
	 Fonte: cheques_limite_valida_proposta.php
	 Autor: David                                                 
	 Data : Junho/2010                          Última Alteração: 11/12/2017
	                                                                  
	 Objetivo  : Validar dados da proposta do limite				 
	                                                                  	 
	 Alterações: 21/11/2012 - Ajustes referente ao projeto GE (Adriano).
   
                 11/12/2017 - P404 - Inclusão de Garantia de Cobertura das
                 Operações de Crédito (Augusto / Marcos (Supero))

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

	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["diaratin"]) ||
		!isset($_POST["vllimite"]) ||
		!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"]) ||
		!isset($_POST["dtrating"]) ||
		!isset($_POST["cddlinha"]) ||
		!isset($_POST["vlrrisco"]) ||
		!isset($_POST["inconfir"]) || 
		!isset($_POST["inconfi2"]) ||
		!isset($_POST["inconfi4"]) ||
		!isset($_POST["inconfi5"]) ||
		!isset($_POST["cddopcao"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$diaratin = $_POST["diaratin"];
	$vllimite = $_POST["vllimite"];
	$dtrating = $_POST["dtrating"];
	$vlrrisco = $_POST["vlrrisco"];
	$cddlinha = $_POST["cddlinha"];
	$inconfir = $_POST["inconfir"];
	$inconfi2 = $_POST["inconfi2"];
	$inconfi4 = $_POST["inconfi4"];
	$inconfi5 = $_POST["inconfi5"];
	$cddopcao = $_POST["cddopcao"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se a data do rating é válida
	if (!validaData($dtrating)) {
		exibeErro("Data de rating inv&aacute;lida.");
	}	

	
	// Monta o xml de requisição
	$xmlValidaProposta  = "";
	$xmlValidaProposta .= "<Root>";
	$xmlValidaProposta .= "	<Cabecalho>";
	$xmlValidaProposta .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlValidaProposta .= "		<Proc>valida_proposta_dados</Proc>";
	$xmlValidaProposta .= "	</Cabecalho>";
	$xmlValidaProposta .= "	<Dados>";
	$xmlValidaProposta .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlValidaProposta .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlValidaProposta .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlValidaProposta .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlValidaProposta .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlValidaProposta .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlValidaProposta .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlValidaProposta .= "		<idseqttl>1</idseqttl>";
	$xmlValidaProposta .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlValidaProposta .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlValidaProposta .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlValidaProposta .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlValidaProposta .= "		<diaratin>".$diaratin."</diaratin>";
	$xmlValidaProposta .= "		<vllimite>".$vllimite."</vllimite>";
	$xmlValidaProposta .= "		<dtrating>".$dtrating."</dtrating>";
	$xmlValidaProposta .= "		<vlrrisco>".$vlrrisco."</vlrrisco>";
	$xmlValidaProposta .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xmlValidaProposta .= "		<cddlinha>".$cddlinha."</cddlinha>";
	$xmlValidaProposta .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlValidaProposta .= "		<inconfi2>".$inconfi2."</inconfi2>";
	$xmlValidaProposta .= "		<inconfi4>".$inconfi4."</inconfi4>";
	$xmlValidaProposta .= "		<inconfi5>".$inconfi5."</inconfi5>";
	$xmlValidaProposta .= "	</Dados>";
	$xmlValidaProposta .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlValidaProposta);

	// Cria objeto para classe de tratamento de XML
	$xmlObjValidaProposta = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjValidaProposta->roottag->tags[0]->name) == "ERRO") {
	
		$aux_mensagem = $xmlObjValidaProposta->roottag->tags[1]->tags[0]->tags[1]->cdata;
	    $aux_inconfir = $xmlObjValidaProposta->roottag->tags[1]->tags[0]->tags[0]->cdata;	
		$grupo 		  = $xmlObjValidaProposta->roottag->tags[2]->tags;  
		
		
		//Se a conta em questão excedeu o limite legal e fizer parte de algum grupo economico então, será mostrado todas as contas deste grupo.
		if($aux_inconfir == 19 && count($grupo) > 0){
											
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
			echo 'dsmetodo = \'showError("error","'.$xmlObjValidaProposta->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","'.$metodo.'"     );\';';
			
			echo 'hideMsgAguardo();';
			echo 'showError("inform","'.$aux_mensagem.'","Alerta - Aimaro","mostraMsgsGrupoEconomico();formataGrupoEconomico();");';
						
			exit();
			
		
		}elseif($aux_inconfir == 19){ 
		
			echo 'hideMsgAguardo();';
			echo 'showError("inform","'.$aux_mensagem.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();showError(\'error\',\''.$xmlObjValidaProposta->roottag->tags[0]->tags[0]->tags[4]->cdata.'\',\'Alerta - Aimaro\',\'blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))\');");';
			exit();
			
		}else{
			exibeErro($xmlObjValidaProposta->roottag->tags[0]->tags[0]->tags[4]->cdata);
			
		}
		
	} 

	$qtMensagens = count($xmlObjValidaProposta->roottag->tags[0]->tags);
	$mensagem    = $xmlObjValidaProposta->roottag->tags[0]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjValidaProposta->roottag->tags[0]->tags[$qtMensagens - 1]->tags[0]->cdata;	
	
	
	if ($inconfir == 2) {
	
		echo 'hideMsgAguardo();';
		echo 'aux_inconfir = "'.$inconfir.'";';
		echo 'showConfirmacao("'.$mensagem.'","Confirma&ccedil;&atilde;o - Aimaro","validaLimiteDscChq(\''.$cddopcao.'\',aux_inconfir,aux_inconfi2,aux_inconfi5)","metodoBlock()","sim.gif","nao.gif");';
		exit();
		
	} elseif ($inconfir == 12) {
	
		echo 'hideMsgAguardo();';
		echo 'aux_inconfi2 = "'.$inconfir.'";';
		echo 'showConfirmacao("'.$mensagem.'","Confirma&ccedil;&atilde;o - Aimaro","validaLimiteDscChq(\''.$cddopcao.'\',aux_inconfir,aux_inconfi2,aux_inconfi5)","metodoBlock()","sim.gif","nao.gif");';
		exit();
		
	} elseif ($inconfir == 31) {
	
		echo 'hideMsgAguardo();';
		echo 'aux_inconfi5 = '.$inconfir.' + 1;';
		echo 'showConfirmacao("'.$mensagem.'","Confirma&ccedil;&atilde;o - Aimaro","validaLimiteDscChq(\''.$cddopcao.'\',aux_inconfir,aux_inconfi2,aux_inconfi5)","metodoBlock()","sim.gif","nao.gif");';
		exit();
		
	}

	// Mostra div para com informações de Renda
	//echo 'dscShowHideDiv("divDscChq_Renda;divBotoesRenda","divDscChq_Limite;divBotoesLimite");';	
    // Abre tela de garantia
    echo 'abrirTelaGAROPC("'.$cddopcao.'");';

	// Esconde mensagem de aguardo e bloqueia conteúdo que está átras do div da rotina
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';

	// Mostra informação e continua
	if ($inconfir == 72) { 
		echo 'showError("inform","'.$mensagem.'","Alerta - Aimaro","metodoBlock()");';
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>