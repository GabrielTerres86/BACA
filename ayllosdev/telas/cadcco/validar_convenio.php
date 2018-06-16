<?php 
	/*******************************************************************************
	 Fonte: validar_convenio.php                                                 
	 Autor: Jonathan - RKAM                                                    
	 Data : Marco/2016                   Última Alteração:  
	                                                                  
	 Objetivo  : Efetua a validacao do convenio de cobrança.                                  
	                                                                  
	 Alterações: 30/11/2016 - P341-Automatização BACENJUD - Alterado para passar como parametro o  
                              código do departamento ao invés da descrição (Renato Darosci - Supero)
							  
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
	$nmdbanco = (isset($_POST['nmdbanco'])) ? $_POST['nmdbanco'] : '';
	$cdbccxlt = (isset($_POST['cdbccxlt'])) ? $_POST['cdbccxlt'] : 0;
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
	$nrdolote = (isset($_POST['nrdolote'])) ? $_POST['nrdolote'] : 0;
	$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0;
	$nrlotblq = (isset($_POST['nrlotblq'])) ? $_POST['nrlotblq'] : 0;
	$nrvarcar = (isset($_POST['nrvarcar'])) ? $_POST['nrvarcar'] : 0;
	$cdcartei = (isset($_POST['cdcartei'])) ? $_POST['cdcartei'] : 0;
	$nrbloque = (isset($_POST['nrbloque'])) ? $_POST['nrbloque'] : 0;
	$dsorgarq = (isset($_POST['dsorgarq'])) ? $_POST['dsorgarq'] : '';
	$tamannro = (isset($_POST['tamannro'])) ? $_POST['tamannro'] : '';
	$nmdireto = (isset($_POST['nmdireto'])) ? $_POST['nmdireto'] : '';
	$nmarquiv = (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '';
	$flcopcob = (isset($_POST['flcopcob'])) ? $_POST['flcopcob'] : 0;
	$flgativo = (isset($_POST['flgativo'])) ? $_POST['flgativo'] : 0;
	$flgregis = (isset($_POST['flgregis'])) ? $_POST['flgregis'] : 0;
	$flprotes = (isset($_POST['flprotes'])) ? $_POST['flprotes'] : 0;
	$insrvprt = (isset($_POST['insrvprt'])) ? $_POST['insrvprt'] : 0;
	$flserasa = (isset($_POST['flserasa'])) ? $_POST['flserasa'] : 0;
	$qtdfloat = (isset($_POST['qtdfloat'])) ? $_POST['qtdfloat'] : 0;
	$qtfltate = (isset($_POST['qtfltate'])) ? $_POST['qtfltate'] : 0;
	$qtdecini = (isset($_POST['qtdecini'])) ? $_POST['qtdecini'] : 0;
	$qtdecate = (isset($_POST['qtdecate'])) ? $_POST['qtdecate'] : 0;
	$fldctman = (isset($_POST['fldctman'])) ? $_POST['fldctman'] : 0;
	$perdctmx = (isset($_POST['perdctmx'])) ? $_POST['perdctmx'] : 0;
	$flgapvco = (isset($_POST['flgapvco'])) ? $_POST['flgapvco'] : 0;
	$flrecipr = (isset($_POST['flrecipr'])) ? $_POST['flrecipr'] : 0;

	
	validaDados();

	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml       .=		"<nrconven>".$nrconven."</nrconven>";
	$xml       .=		"<cddbanco>".$cddbanco."</cddbanco>";
	$xml       .=		"<nmdbanco>".$nmdbanco."</nmdbanco>";
	$xml       .=		"<nrdctabb>".$nrdctabb."</nrdctabb>";
	$xml       .=		"<cdbccxlt>".$cdbccxlt."</cdbccxlt>";
	$xml       .=		"<cdagenci>".$cdagenci."</cdagenci>";
	$xml       .=		"<nrdolote>".$nrdolote."</nrdolote>";
	$xml       .=		"<cdhistor>".$cdhistor."</cdhistor>";
	$xml       .=		"<nrlotblq>".$nrlotblq."</nrlotblq>";
	$xml       .=		"<nrvarcar>".$nrvarcar."</nrvarcar>";
	$xml       .=		"<cdcartei>".$cdcartei."</cdcartei>";
	$xml       .=		"<nrbloque>".$nrbloque."</nrbloque>";
	$xml       .=		"<dsorgarq>".$dsorgarq."</dsorgarq>";
	$xml       .=		"<tamannro>".$tamannro."</tamannro>";
	$xml       .=		"<nmdireto>".$nmdireto."</nmdireto>";
	$xml       .=		"<nmarquiv>".$nmarquiv."</nmarquiv>";
	$xml       .=		"<flcopcob>".$flcopcob."</flcopcob>";
	$xml       .=		"<flgativo>".$flgativo."</flgativo>";
	$xml       .=		"<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml       .=		"<flgregis>".$flgregis."</flgregis>";
	$xml       .=		"<flprotes>".$flprotes."</flprotes>";
	$xml       .=		"<insrvprt>".$insrvprt."</insrvprt>";
	$xml       .=		"<flserasa>".$flserasa."</flserasa>";
	$xml       .=		"<qtdfloat>".$qtdfloat."</qtdfloat>";
	$xml       .=		"<qtfltate>".$qtfltate."</qtfltate>";
	$xml       .=		"<qtdecini>".$qtdecini."</qtdecini>";
	$xml       .=		"<qtdecate>".$qtdecate."</qtdecate>";
	$xml       .=		"<fldctman>".$fldctman."</fldctman>";
	$xml       .=		"<perdctmx>".$perdctmx."</perdctmx>";
	$xml       .=		"<flgapvco>".$flgapvco."</flgapvco>";
	$xml       .=		"<flrecipr>".$flrecipr."</flrecipr>";	
	$xml       .=		"<cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xml       .=		"<cddopcao>".$cddopcao."</cddopcao>";
	$xml       .=		"<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
						
	$xmlResult = mensageria($xml, "TELA_CADCCO", "VALIDACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjAltera = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAltera->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjAltera->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjAltera->roottag->tags[0]->attributes["NMDCAMPO"];

		if(empty ($nmdcampo)){ 
			$nmdcampo = "flgativo";
		}

		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','formataInformacoes();focaCampoErro(\''.$nmdcampo.'\',\'frmCadcco\');',false);		
					
	}
	
	echo 'mostraConfrp();';
	
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
	
	}
					
?>
