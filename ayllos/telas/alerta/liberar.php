<?php

	/*************************************************************************
	  Fonte: liberar.php                                               
	  Autor: Adriano                                                  
	  Data : Fevereiro/2013                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Rotina de liberação da tela ALERTA.              
	                                                                 
	  Alterações: 										   			  
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'L')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["cdcoplib"]) || 
	    !isset($_POST["cdagelib"]) || 
		!isset($_POST["cdopelib"]) ||
	    !isset($_POST["nrdconta"]) || 
		!isset($_POST["nrcpfcgc"]) ||
		!isset($_POST["dsjuslib"]) ||
		!isset($_POST["cdoperac"]) ) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
		
	}	
	
	$cdcoplib = $_POST["cdcoplib"];
	$cdagelib = $_POST["cdagelib"];	
	$cdopelib = $_POST["cdopelib"];
	$nrdconta = $_POST["nrdconta"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$dsjuslib = $_POST["dsjuslib"];
	$cdoperac = $_POST["cdoperac"];
	
		
	validaDados();

		
	$xmlLiberar  = "";
	$xmlLiberar .= "<Root>";
	$xmlLiberar .= " <Cabecalho>";
	$xmlLiberar .= "    <Bo>b1wgen0117.p</Bo>";
	$xmlLiberar .= "    <Proc>liberar_cad_restritivo</Proc>";
	$xmlLiberar .= " </Cabecalho>";
	$xmlLiberar .= " <Dados>";
	$xmlLiberar .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlLiberar .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlLiberar .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlLiberar .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlLiberar .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlLiberar .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlLiberar .= "    <cdcoplib>".$cdcoplib."</cdcoplib>";
	$xmlLiberar .= "    <cdagelib>".$cdagelib."</cdagelib>";
	$xmlLiberar .= "    <cdopelib>".$cdopelib."</cdopelib>";
	$xmlLiberar .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xmlLiberar .= "	<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlLiberar .= "	<dsjuslib>".$dsjuslib."</dsjuslib>";
	$xmlLiberar .= "	<cdoperac>".$cdoperac."</cdoperac>";
	$xmlLiberar .= "	<flgsiste>false</flgsiste>";
	$xmlLiberar .= " </Dados>";
	$xmlLiberar .= "</Root>";
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlLiberar);
		
	$xmlObjLiberar = getObjectXML($xmlResult);
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLiberar->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjLiberar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjLiberar->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input,textarea','#frmLiberar').removeClass('campoErro');unblockBackground(); focaCampoErro('#".$nmdcampo."','frmLiberar');";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
							
	}    
		
	
	include('form_liberar.php');	
	
	?>
		<script type="text/javascript">
			limpaCampos('L');
			formataLiberar();
			controlaLayout('L');
		</script>
	<?	

	function validaDados(){
		
		//Cooperativa Solicitante
		if ( $GLOBALS["cdcoplib"] == ''  ){
			exibirErro('error','O campo Cooperativa Solicitante n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'cdcopsol\',\'frmLiberar\');',false);
		}		
		
		//Agencia
		if ( $GLOBALS["cdagelib"] == ''  ){ 
			exibirErro('error','O campo Ag&ecirc;ncia n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'cdagepac\',\'frmLiberar\');',false);
		}	
					
		//Operador
		if ( $GLOBALS["cdopelib"] == ''  ){ 
			exibirErro('error','O campo Operador Autirizado n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'cdopelib\',\'frmLiberar\');',false);
		}
		
		//Conta
		if ( $GLOBALS["nrdconta"] == ''  ){ 
			exibirErro('error','O campo Conta Autorizada n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmLiberar\');',false);
		}
		
		//CPF/CNPJ
		if ( $GLOBALS["nrcpfcgc"] == 0  ){ 
			exibirErro('error','O campo CPF/CNPJ n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'nrcpfcgc\',\'frmLiberar\');',false);
		}
		
		//Operacao
		if ( $GLOBALS["cdoperac"] == ''  ){ 
			exibirErro('error','O campo Opera&ccedil;&atilde;o Autorizada n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'cdoperac\',\'frmLiberar\');',false);
		}
		
		//Justificativa
		if ( $GLOBALS["dsjuslib"] == ''  ){ 
			exibirErro('error','O campo Justificativa de Libera&ccedil;&atilde;o n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'dsjuslib\',\'frmLiberar\');',false);
		}
			
	}
	
?>
