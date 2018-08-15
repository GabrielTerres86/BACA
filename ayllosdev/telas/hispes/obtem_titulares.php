<?php 

	    /*!
     * FONTE        : obtem_titulares.php
     * CRIAÇÃO      : Odirlei Busana(AMcom)
     * DATA CRIAÇÃO : Novembro/2017 
     * OBJETIVO     : Retorna dados dos titulares e tipo de contas
     * --------------
     * ALTERAÇÕES   :
     * --------------
     *
     */	     
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	if (!isset($_POST["nrdconta"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
			
	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
    $cdcooper = $_POST["cdcooper"] == "" ? 0 : $_POST["cdcooper"];
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inválida.");
	}	

    // Se conta informada não for um número inteiro válido
	if (!validaInteiro($cdcooper)) {
		exibeErro("Cooperativa inválida.");
	}	

	// Monta o xml de requisição
	$xmlGetDadosTitular  = "";
	$xmlGetDadosTitular .= "<Root>";
	$xmlGetDadosTitular .= "	<Cabecalho>";
	$xmlGetDadosTitular .= "		<Bo>b1wgen0051.p</Bo>";
	$xmlGetDadosTitular .= "		<Proc>busca_dados_associado</Proc>";
	$xmlGetDadosTitular .= "	</Cabecalho>";
	$xmlGetDadosTitular .= "	<Dados>";
	$xmlGetDadosTitular .= "		<cdcooper>".$cdcooper."</cdcooper>";
	$xmlGetDadosTitular .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosTitular .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosTitular .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosTitular .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosTitular .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosTitular .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosTitular .= "	</Dados>";
	$xmlGetDadosTitular .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosTitular);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosTitular = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosTitular->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosTitular->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$TpNatureza = $xmlObjDadosTitular->roottag->tags[0]->tags[0]->tags[0]->cdata;
	
	function exibeErro($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Contas","$(\'#nrdconta\',\'#frmCabContas\').focus()");';
		exit();	
	}
	
	//Popula o combo de titulares
	echo 'var strHTML = \'\';';
	
	if ($TpNatureza == 2) { // Pessoa Jurídica
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';		
		exit();
	} else {                // Pessoa Física
		$totalReg = count($xmlObjDadosTitular->roottag->tags[1]->tags);
		for ($i = 1; $i <= $totalReg; $i++){
			// seleciona por padrão sempre o primeiro registro
			if ($i == 1) { 
				$selected = ' selected="selected"'; 
			} else {
				$selected = '';
			}
			//monta string dos options
			echo 'strHTML += \'<option value="'.$xmlObjDadosTitular->roottag->tags[1]->tags[$i - 1]->tags[0]->cdata.'"'.$selected.'>'.
					$xmlObjDadosTitular->roottag->tags[1]->tags[$i - 1]->tags[0]->cdata.' - '.
					$xmlObjDadosTitular->roottag->tags[1]->tags[$i - 1]->tags[1]->cdata.'</option>\';';
                    
            if ($xmlObjDadosTitular->roottag->tags[1]->tags[$i - 1]->tags[0]->cdata == 1 ){
              echo '$("#nmpessoa","#frmCab").val("'.$xmlObjDadosTitular->roottag->tags[1]->tags[$i - 1]->tags[1]->cdata.'");';    
            }
            
        }
	}
	echo '$("#idseqttl").html(strHTML);';	
	echo '$("#idseqttl","#frmCab").val("1");'; // fixo, tela não está respeitando o selected
	echo '$("#nrdconta","#frmCab").val("'.$nrdconta.'").formataDado("INTEGER","zzzz.zzz-z","",false);';
    echo '$("#tppessoa","#frmCab").val("'.$TpNatureza.'");';
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
		
?>
