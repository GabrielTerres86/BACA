<?php 

	    /*!
     * FONTE        : obtem_titulares.php
     * CRIA��O      : Odirlei Busana(AMcom)
     * DATA CRIA��O : Novembro/2017 
     * OBJETIVO     : Retorna dados dos titulares e tipo de contas
     * --------------
     * ALTERA��ES   :
     * --------------
     *
     */	     
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	if (!isset($_POST["nrdconta"]))  {
		exibeErro("Par�metros incorretos.");
	}	
			
	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
    $cdcooper = $_POST["cdcooper"] == "" ? 0 : $_POST["cdcooper"];
	
	// Se conta informada n�o for um n�mero inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv�lida.");
	}	

    // Se conta informada n�o for um n�mero inteiro v�lido
	if (!validaInteiro($cdcooper)) {
		exibeErro("Cooperativa inv�lida.");
	}	

	// Monta o xml de requisi��o
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
		
	// Se ocorrer um erro, mostra cr�tica
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
	
	if ($TpNatureza == 2) { // Pessoa Jur�dica
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';		
		exit();
	} else {                // Pessoa F�sica
		$totalReg = count($xmlObjDadosTitular->roottag->tags[1]->tags);
		for ($i = 1; $i <= $totalReg; $i++){
			// seleciona por padr�o sempre o primeiro registro
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
	echo '$("#idseqttl","#frmCab").val("1");'; // fixo, tela n�o est� respeitando o selected
	echo '$("#nrdconta","#frmCab").val("'.$nrdconta.'").formataDado("INTEGER","zzzz.zzz-z","",false);';
    echo '$("#tppessoa","#frmCab").val("'.$TpNatureza.'");';
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
		
?>
