<?php 
	/*******************************************************************************
	 Fonte: incluir_convenio.php                                                 
	 Autor: Jonathan - RKAM                                                    
	 Data : Fevereiro/2016                   Última Alteração:  
	                                                                  
	 Objetivo  : Efetua a inclusão do convenio de cobrança.                                  
	                                                                  
	 Alterações: 
							  
	********************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Guardo os parâmetos do POST em variáveis	
	$nrconven = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0;
	$cddbanco = (isset($_POST['cddbanco'])) ? $_POST['cddbanco'] : 0;
	$nrdctabb = (isset($_POST['nrdctabb'])) ? $_POST['nrdctabb'] : 0;	
	$cdbccxlt = (isset($_POST['cdbccxlt'])) ? $_POST['cdbccxlt'] : 0;
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
	$nrdolote = (isset($_POST['nrdolote'])) ? $_POST['nrdolote'] : 0;
	$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0;
	$vlrtarif = (isset($_POST['vlrtarif'])) ? $_POST['vlrtarif'] : 0;
	$cdtarhis = (isset($_POST['cdtarhis'])) ? $_POST['cdtarhis'] : 0;
	$cdhiscxa = (isset($_POST['cdhiscxa'])) ? $_POST['cdhiscxa'] : 0;
	$vlrtarcx = (isset($_POST['vlrtarcx'])) ? $_POST['vlrtarcx'] : 0;
	$cdhisnet = (isset($_POST['cdhisnet'])) ? $_POST['cdhisnet'] : 0;
	$vlrtarnt = (isset($_POST['vlrtarnt'])) ? $_POST['vlrtarnt'] : 0;
	$cdhistaa = (isset($_POST['cdhistaa'])) ? $_POST['cdhistaa'] : 0;
	$vltrftaa = (isset($_POST['vltrftaa'])) ? $_POST['vltrftaa'] : 0;
	$nrlotblq = (isset($_POST['nrlotblq'])) ? $_POST['nrlotblq'] : 0;
	$nrvarcar = (isset($_POST['nrvarcar'])) ? $_POST['nrvarcar'] : 0;
	$cdcartei = (isset($_POST['cdcartei'])) ? $_POST['cdcartei'] : 0;
	$vlrtrblq = (isset($_POST['vlrtrblq'])) ? $_POST['vlrtrblq'] : 0;
	$cdhisblq = (isset($_POST['cdhisblq'])) ? $_POST['cdhisblq'] : 0;
	$nrbloque = (isset($_POST['nrbloque'])) ? $_POST['nrbloque'] : 0;
	$dsorgarq = (isset($_POST['dsorgarq'])) ? $_POST['dsorgarq'] : '';
	$tamannro = (isset($_POST['tamannro'])) ? $_POST['tamannro'] : '';
	$nmdireto = (isset($_POST['nmdireto'])) ? $_POST['nmdireto'] : '';
	$nmarquiv = (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '';
	$flgutceb = (isset($_POST['flgutceb'])) ? $_POST['flgutceb'] : 0;
	$flcopcob = (isset($_POST['flcopcob'])) ? $_POST['flcopcob'] : 0;
	$flserasa = (isset($_POST['flserasa'])) ? $_POST['flserasa'] : 0;	
	$flgativo = (isset($_POST['flgativo'])) ? $_POST['flgativo'] : 0;
	$flgregis = (isset($_POST['flgregis'])) ? $_POST['flgregis'] : 0;
	$qtdfloat = (isset($_POST['qtdfloat'])) ? $_POST['qtdfloat'] : 0;	
	
	validaDados();

	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml       .=		"<nrconven>".$nrconven."</nrconven>";
	$xml       .=		"<cddbanco>".$cddbanco."</cddbanco>";	
	$xml       .=		"<nrdctabb>".$nrdctabb."</nrdctabb>";
	$xml       .=		"<cdbccxlt>".$cdbccxlt."</cdbccxlt>";
	$xml       .=		"<cdagenci>".$cdagenci."</cdagenci>";
	$xml       .=		"<nrdolote>".$nrdolote."</nrdolote>";
	$xml       .=		"<cdhistor>".$cdhistor."</cdhistor>";
	$xml       .=		"<vlrtarif>".$vlrtarif."</vlrtarif>";
	$xml       .=		"<cdtarhis>".$cdtarhis."</cdtarhis>";
	$xml       .=		"<cdhiscxa>".$cdhiscxa."</cdhiscxa>";
	$xml       .=		"<vlrtarcx>".$vlrtarcx."</vlrtarcx>";
	$xml       .=		"<cdhisnet>".$cdhisnet."</cdhisnet>";
	$xml       .=		"<vlrtarnt>".$vlrtarnt."</vlrtarnt>";
	$xml       .=		"<cdhistaa>".$cdhistaa."</cdhistaa>";
	$xml       .=		"<vltrftaa>".$vltrftaa."</vltrftaa>";
	$xml       .=		"<nrlotblq>".$nrlotblq."</nrlotblq>";
	$xml       .=		"<nrvarcar>".$nrvarcar."</nrvarcar>";
	$xml       .=		"<cdcartei>".$cdcartei."</cdcartei>";
	$xml       .=		"<vlrtrblq>".$vlrtrblq."</vlrtrblq>";
	$xml       .=		"<cdhisblq>".$cdhisblq."</cdhisblq>";
	$xml       .=		"<nrbloque>".$nrbloque."</nrbloque>";
	$xml       .=		"<dsorgarq>".$dsorgarq."</dsorgarq>";
	$xml       .=		"<tamannro>".$tamannro."</tamannro>";
	$xml       .=		"<nmdireto>".$nmdireto."</nmdireto>";
	$xml       .=		"<nmarquiv>".$nmarquiv."</nmarquiv>";
	$xml       .=		"<flgutceb>".$flgutceb."</flgutceb>";
	$xml       .=		"<flcopcob>".$flcopcob."</flcopcob>";
	$xml       .=		"<flserasa>".$flserasa."</flserasa>";
	$xml       .=		"<flgativo>".$flgativo."</flgativo>";
	$xml       .=		"<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml       .=		"<flgregis>".$flgregis."</flgregis>";
	$xml       .=		"<qtdfloat>".$qtdfloat."</qtdfloat>";
	$xml       .=		"<dsdepart>".$glbvars["dsdepart"]."</dsdepart>";
	$xml       .=		"<cddopcao>".$cddopcao."</cddopcao>";
	$xml       .=		"<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
						
	$xmlResult = mensageria($xml, "TELA_CADCCO", "INCLUSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjInclui = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjInclui->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjInclui->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjInclui->roottag->tags[0]->attributes["NMDCAMPO"];

		if(empty ($nmdcampo)){ 
			$nmdcampo = "flgativo";
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos','formataInformacoes();focaCampoErro(\''.$nmdcampo.'\',\'frmCadcco\');',false);		
					
	}else{
		
		if($flgregis == '1'){
			                             
			exibirErro('inform','Conv&ecirc;nio inclu&iacute;do com sucesso!','Alerta - Ayllos','buscaTarifas(\'1\',\'30\',\''.$nrconven.'\',\''.$cddbanco.'\');',false);                              

		}else{
			exibirErro('inform','Conv&ecirc;nio inclu&iacute;do com sucesso!','Alerta - Ayllos','estadoInicial();',false); 
		}
	}


	function validaDados(){

		//Convenio
		if ( $GLOBALS["nrconven"] == 0){ 
			exibirErro('error','Conv&ecirc;nio inv&aacute;lido.','Alerta - Ayllos','formataInformacoes();$(\'#nrconven\',\'#frmCadcco\').focus();',false);
		}

		//Conta base
		if ( $GLOBALS["nrdctabb"] == 0){ 
			exibirErro('error','Conta base inv&aacute;lida.','Alerta - Ayllos','formataInformacoes();$(\'#nrdctabb\',\'#frmCadcco\').focus();',false);
		}

		//Banco
		if ( $GLOBALS["cddbanco"] == 0){ 
			exibirErro('error','Banco inv&aacute;lido.','Alerta - Ayllos','formataInformacoes();$(\'#cddbanco\',\'#frmCadcco\').focus();',false);
		}

		//Banco/caixa
		if ( $GLOBALS["cdbccxlt"] == 0){ 
			exibirErro('error','Banco/Caixa inv&aacute;lido.','Alerta - Ayllos','formataInformacoes();$(\'#cdbccxlt\',\'#frmCadcco\').focus();',false);
		}

		//Agência
		if ( $GLOBALS["cdagenci"] == 0){ 
			exibirErro('error','Ag&ecirc;ncia inv&aacute;lida.','Alerta - Ayllos','formataInformacoes();$(\'#cdagenci\',\'#frmCadcco\').focus();',false);
		}

		//Lote
		if ( $GLOBALS["nrdolote"] == 0){ 
			exibirErro('error','Lote inv&aacute;lido.','Alerta - Ayllos','formataInformacoes();$(\'#nrdolote\',\'#frmCadcco\').focus();',false);
		
		}

		//Histórico
		if ( $GLOBALS["cdhistor"] == 0){ 
			exibirErro('error','Hist&oacute;rico inv&aacute;lido.','Alerta - Ayllos','formataInformacoes();$(\'#cdhistor\',\'#frmCadcco\').focus();',false);
		}

		//Nome do arquivo
		if ( $GLOBALS["nmarquiv"] == ''){ 
			exibirErro('error','Nome do arquivo inv&aacute;lido.','Alerta - Ayllos','formataInformacoes();$(\'#nmarquiv\',\'#frmCadcco\').focus();',false);
		
		}			

		//Historico da tarifa
		if ( $GLOBALS["vlrtarif"] > 0 && $GLOBALS["cdtarhis"] == 0){ 
			exibirErro('error','Hist&oacute;rico deve ser informado!','Alerta - Ayllos','formataInformacoes();$(\'#cdtarhis\',\'#frmCadcco\').focus();',false);
		}

		//Historico da tarifa do caixa
		if ( $GLOBALS["vlrtarcx"] > 0 && $GLOBALS["cdhiscxa"] == 0){ 
			exibirErro('error','Hist&oacute;rico deve ser informado!','Alerta - Ayllos','formataInformacoes();$(\'#cdhiscxa\',\'#frmCadcco\').focus();',false);
		}

		//Historico da tarifa da internet
		if ( $GLOBALS["vlrtarnt"] > 0 && $GLOBALS["cdhisnet"] == 0){ 
			exibirErro('error','Hist&oacute;rico deve ser informado!','Alerta - Ayllos','formataInformacoes();$(\'#cdhisnet\',\'#frmCadcco\').focus();',false);
		}

		//Historico da tarifa da internet
		if ( $GLOBALS["vltrftaa"] > 0 && $GLOBALS["cdhistaa"] == 0){ 
			exibirErro('error','Hist&oacute;rico deve ser informado!','Alerta - Ayllos','formataInformacoes();$(\'#cdhistaa\',\'#frmCadcco\').focus();',false);
		}

		//Historico da tarifa de bloqueto
		if ( $GLOBALS["vlrtrblq"] > 0 && $GLOBALS["cdhisblq"] == 0){ 
			exibirErro('error','Hist&oacute;rico deve ser informado!','Alerta - Ayllos','formataInformacoes();$(\'#cdhisblq\',\'#frmCadcco\').focus();',false);
		}
	
	}
					
?>
