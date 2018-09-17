<?php

	/*************************************************************************
	  Fonte: incluir.php                                               
	  Autor: Adriano                                                  
	  Data : Fevereiro/2013                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Rotina de inclusao da tela ALERTA.              
	                                                                 
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrcpfcgc"]) || 
	    !isset($_POST["nmpessoa"]) || 
		!isset($_POST["cdcopsol"]) ||
	    !isset($_POST["nmpessol"]) || 
		!isset($_POST["dsjusinc"]) ||
		!isset($_POST["cdbccxlt"]) || 
		!isset($_POST["tporigem"]) ) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
		
	}	
	
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$nmpessoa = $_POST["nmpessoa"];	
	$cdcopsol = $_POST["cdcopsol"] == '' ? 0 : $_POST["cdcopsol"];
	$nmpessol = $_POST["nmpessol"];
	$cdopeinc = $_POST["cdopeinc"];
	$dsjusinc = $_POST["dsjusinc"];
	$cdbccxlt = $_POST["cdbccxlt"] == '' ? 0 : $_POST["cdbccxlt"];
	$tporigem = $_POST["tporigem"];
	
				
	validaDados();		
		
			
	$xmlIncluir  = "";
	$xmlIncluir .= "<Root>";
	$xmlIncluir .= " <Cabecalho>";
	$xmlIncluir .= "    <Bo>b1wgen0117.p</Bo>";
	$xmlIncluir .= "    <Proc>incluir_cad_restritivo</Proc>";
	$xmlIncluir .= " </Cabecalho>";
	$xmlIncluir .= " <Dados>";
	$xmlIncluir .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlIncluir .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlIncluir .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlIncluir .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlIncluir .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlIncluir .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlIncluir .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlIncluir .= "    <nmpessoa>".$nmpessoa."</nmpessoa>";
	$xmlIncluir .= "    <cdcopsol>".$cdcopsol."</cdcopsol>";
	$xmlIncluir .= "	<nmpessol>".$nmpessol."</nmpessol>";
	$xmlIncluir .= "	<cdbccxlt>".$cdbccxlt."</cdbccxlt>";
	$xmlIncluir .= "	<dsjusinc>".$dsjusinc."</dsjusinc>";
	$xmlIncluir .= "	<tporigem>".$tporigem."</tporigem>";
	
	$xmlIncluir .= " </Dados>";
	$xmlIncluir .= "</Root>";
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlIncluir);
		
	$xmlObjIncluir = getObjectXML($xmlResult);
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjIncluir->roottag->tags[0]->name) == "ERRO") {
						
		$msgErro = $xmlObjIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjIncluir->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input,select,textarea','#frmIncluir').removeClass('campoErro');unblockBackground(); focaCampoErro('#".$nmdcampo."','frmIncluir');";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
				
	}    
	
	include('form_incluir.php');	
	
	?>
		<script type="text/javascript">
		
			$('input,select,textarea','#frmIncluir').removeClass('campoErro');
			controlaLayout('I');
			formataIncluir();
			
		</script>
		
	<?
	
	
	$msgRetorno = $xmlObjIncluir->roottag->tags[0]->attributes['MSGRETOR'];
	
		
	/*Se CPF/CNPJ já está ou já esteve cadastrado*/
	if($msgRetorno != 0){
	
		if($msgRetorno == 1) {?>
		
			<script type="text/javascript">
				
				showError("inform","O CPF/CNPJ j&aacute; est&aacute; cadastrado.","Alerta - Ayllos","consultaVinculo('I','.<?echo $nrcpfcgc;?>.',1,30);");
				
			</script>
			
			
		<?}else if($msgRetorno == 2){ ?> 
		
				<script type="text/javascript">
					showError("inform","O CPF/CNPJ j&aacute; esteve cadastrado.","Alerta - Ayllos","consultaVinculo('I','.<?echo $nrcpfcgc;?>.',1,30);");
				</script>
				
		<?}
		
	}else{ ?> 
		
		<script type="text/javascript">
		
			consultaVinculo('I','.<?echo $nrcpfcgc;?>.',1,30);
			
		</script>
				
	<?}
			
	function validaDados(){		
			
		//CPF/CNPJ
		if ( $GLOBALS['nrcpfcgc'] == 0  ){ 
			exibirErro('error','O campo CPF/CNPJ n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'nrcpfcgc\',\'frmIncluir\');',false);
		}
			
		//Nome
		if ( $GLOBALS['nmpessoa'] == ''  ){
			exibirErro('error','O campo Nome n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'nmpessoa\',\'frmIncluir\');',false);
		}
		
		//Origem
		if ( $GLOBALS['tporigem'] == ''  ){ 
			exibirErro('error','O campo Motivo da Restri&ccedil;&atilde;o n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'tporigem\',\'frmIncluir\');',false);
		}
				
		//Banco
		if ( $GLOBALS['cdbccxlt'] == 0 && $GLOBALS['cdcopsol']  == 0 ){ 
			exibirErro('error','O campo Institui&ccedil;&atilde;o Financeira n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'cdbccxlt\',\'frmIncluir\');',false);
		}
		
		//Cooperativa Solicitante
		if ( $GLOBALS['cdcopsol'] == 0 && $ $GLOBALS['cdbccxlt'] == 0 ){
			exibirErro('error','O campo Cooperativa Solicitante n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'cdcopsol\',\'frmIncluir\');',false);
		}		
		//Pessoa Solicitante
		if ( $GLOBALS['nmpessol'] == ''  ){
			exibirErro('error','O campo Nome Solicitante n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'nmpessol\',\'frmIncluir\');',false);
		}		
		//Motivo
		if ( $GLOBALS['dsjusinc'] == ''  ){ 
			exibirErro('error','O campo Motivo da Inclus&atilde;o n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'dsjusinc\',\'frmIncluir\');',false);
		}
	
	}			 
?>
