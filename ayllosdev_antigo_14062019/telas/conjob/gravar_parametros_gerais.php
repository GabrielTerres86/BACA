<?php
	/*!
	* FONTE        : incluir_jobs.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Junho/2018
	* OBJETIVO     : Rotina para realizar a inclusão das jobs
	* --------------
	* ALTERAÇÕES   : 
	* -------------- 
	*/		
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$nmjobmaster   = isset($_POST["nmjobmaster"])   ? $_POST["nmjobmaster"]   : ""; 
	$numminjob     = isset($_POST["numminjob"])     ? $_POST["numminjob"]     : ""; 
	$qtjobporhor0  = isset($_POST["qtjobporhor0"])  ? $_POST["qtjobporhor0"]  : ""; 
	$qtjobporhor1  = isset($_POST["qtjobporhor1"])  ? $_POST["qtjobporhor1"]  : ""; 
	$qtjobporhor2  = isset($_POST["qtjobporhor2"])  ? $_POST["qtjobporhor2"]  : ""; 
	$qtjobporhor3  = isset($_POST["qtjobporhor3"])  ? $_POST["qtjobporhor3"]  : ""; 
	$qtjobporhor4  = isset($_POST["qtjobporhor4"])  ? $_POST["qtjobporhor4"]  : ""; 
	$qtjobporhor5  = isset($_POST["qtjobporhor5"])  ? $_POST["qtjobporhor5"]  : ""; 
	$qtjobporhor6  = isset($_POST["qtjobporhor6"])  ? $_POST["qtjobporhor6"]  : ""; 
	$qtjobporhor7  = isset($_POST["qtjobporhor7"])  ? $_POST["qtjobporhor7"]  : ""; 
	$qtjobporhor8  = isset($_POST["qtjobporhor8"])  ? $_POST["qtjobporhor8"]  : ""; 
	$qtjobporhor9  = isset($_POST["qtjobporhor9"])  ? $_POST["qtjobporhor9"]  : ""; 
	$qtjobporhor10 = isset($_POST["qtjobporhor10"]) ? $_POST["qtjobporhor10"] : ""; 
	$qtjobporhor11 = isset($_POST["qtjobporhor11"]) ? $_POST["qtjobporhor11"] : ""; 
	$qtjobporhor12 = isset($_POST["qtjobporhor12"]) ? $_POST["qtjobporhor12"] : ""; 
	$qtjobporhor13 = isset($_POST["qtjobporhor13"]) ? $_POST["qtjobporhor13"] : ""; 
	$qtjobporhor14 = isset($_POST["qtjobporhor14"]) ? $_POST["qtjobporhor14"] : ""; 
	$qtjobporhor15 = isset($_POST["qtjobporhor15"]) ? $_POST["qtjobporhor15"] : ""; 
	$qtjobporhor16 = isset($_POST["qtjobporhor16"]) ? $_POST["qtjobporhor16"] : ""; 
	$qtjobporhor17 = isset($_POST["qtjobporhor17"]) ? $_POST["qtjobporhor17"] : ""; 
	$qtjobporhor18 = isset($_POST["qtjobporhor18"]) ? $_POST["qtjobporhor18"] : ""; 
	$qtjobporhor19 = isset($_POST["qtjobporhor19"]) ? $_POST["qtjobporhor19"] : ""; 
	$qtjobporhor20 = isset($_POST["qtjobporhor20"]) ? $_POST["qtjobporhor20"] : ""; 
	$qtjobporhor21 = isset($_POST["qtjobporhor21"]) ? $_POST["qtjobporhor21"] : ""; 
	$qtjobporhor22 = isset($_POST["qtjobporhor22"]) ? $_POST["qtjobporhor22"] : ""; 
	$qtjobporhor23 = isset($_POST["qtjobporhor23"]) ? $_POST["qtjobporhor23"] : ""; 
	$flmailhab     = isset($_POST["flmailhab"])     ? $_POST["flmailhab"]     : "";       
	$flarqhab      = isset($_POST["flarqhab"])      ? $_POST["flarqhab"]      : "";         
	
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nmjobmaster>".$nmjobmaster."</nmjobmaster>";
	$xml .= "   <numminjob>".$numminjob."</numminjob>";
	$xml .= "   <qtjobporhor0>".$qtjobporhor0."</qtjobporhor0 >";
	$xml .= "   <qtjobporhor1>".$qtjobporhor1."</qtjobporhor1 >";
	$xml .= "   <qtjobporhor2>".$qtjobporhor2."</qtjobporhor2 >";
	$xml .= "   <qtjobporhor3>".$qtjobporhor3."</qtjobporhor3 >";
	$xml .= "   <qtjobporhor4>".$qtjobporhor4."</qtjobporhor4 >";
	$xml .= "   <qtjobporhor5>".$qtjobporhor5."</qtjobporhor5 >";
	$xml .= "   <qtjobporhor6>".$qtjobporhor6."</qtjobporhor6 >";
	$xml .= "   <qtjobporhor7>".$qtjobporhor7."</qtjobporhor7 >";
	$xml .= "   <qtjobporhor8>".$qtjobporhor8."</qtjobporhor8 >";
	$xml .= "   <qtjobporhor9>".$qtjobporhor9."</qtjobporhor9 >";
	$xml .= "   <qtjobporhor10>".$qtjobporhor10."</qtjobporhor10>";
	$xml .= "   <qtjobporhor11>".$qtjobporhor11."</qtjobporhor11>";
	$xml .= "   <qtjobporhor12>".$qtjobporhor12."</qtjobporhor12>";
	$xml .= "   <qtjobporhor13>".$qtjobporhor13."</qtjobporhor13>";
	$xml .= "   <qtjobporhor14>".$qtjobporhor14."</qtjobporhor14>";
	$xml .= "   <qtjobporhor15>".$qtjobporhor15."</qtjobporhor15>";
	$xml .= "   <qtjobporhor16>".$qtjobporhor16."</qtjobporhor16>";
	$xml .= "   <qtjobporhor17>".$qtjobporhor17."</qtjobporhor17>";
	$xml .= "   <qtjobporhor18>".$qtjobporhor18."</qtjobporhor18>";
	$xml .= "   <qtjobporhor19>".$qtjobporhor19."</qtjobporhor19>";
	$xml .= "   <qtjobporhor20>".$qtjobporhor20."</qtjobporhor20>";
	$xml .= "   <qtjobporhor21>".$qtjobporhor21."</qtjobporhor21>";
	$xml .= "   <qtjobporhor22>".$qtjobporhor22."</qtjobporhor22>";
	$xml .= "   <qtjobporhor23>".$qtjobporhor23."</qtjobporhor23>";
	$xml .= "   <flmailhab>".$flmailhab."</flmailhab>";
	$xml .= "   <flarqhab>".$flarqhab."</flarqhab>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CONJOB", "CONJOB_GRAVA_PARAMET", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	}
	
	exibirErro('inform','Parâmetros gravados com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
		
	function validaDados(){
		
		if($GLOBALS["nmjobmaster"] == ''){			
            exibirErro('error','O campo Nome JOB Master é obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'nmjobmaster\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["numminjob"] == ''){			
            exibirErro('error','O campo Intervalo Execu&ccedil;&atilde;o JOB Master &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'numminjob\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor0"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 00:00 at&eacute; 01:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor0\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor1"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 01:00 at&eacute; 02:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor1\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor2"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 02:00 at&eacute; 03:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor2\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor3"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 03:00 at&eacute; 04:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor3\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor4"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 04:00 at&eacute; 05:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor4\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor5"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 05:00 at&eacute; 06:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor5\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor6"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 06:00 at&eacute; 07:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor6\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor7"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 07:00 at&eacute; 08:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor7\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor8"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 08:00 at&eacute; 09:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor8\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor9"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 09:00 at&eacute; 10:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor9\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor10"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 10:00 at&eacute; 11:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor10\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor11"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 11:00 at&eacute; 12:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor11\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor12"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 12:00 at&eacute; 13:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor12\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor13"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 13:00 at&eacute; 14:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor13\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor14"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 14:00 at&eacute; 156:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor14\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor15"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 15:00 at&eacute; 16:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor15\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor16"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 16:00 at&eacute; 17:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor16\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor17"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 17:00 at&eacute; 18:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor17\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor18"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 18:00 at&eacute; 19:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor18\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor19"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 19:00 at&eacute; 20:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor19\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor20"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 20:00 at&eacute; 21:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor20\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor21"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 21:00 at&eacute; 22:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor21\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor22"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 22:00 at&eacute; 23:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor22\',\'frmParametrosGerais\');',false);       
		}

		if($GLOBALS["qtjobporhor23"] == ''){			
            exibirErro('error','O campo Quantidade m&aacute;xima de paralelos das: 23:00 at&eacute; 00:00 &eacute; obrigat&oacute;rio.','Alerta - Ayllos','$(\'input, select\',\'#frmParametrosGerais\').removeClass(\'campoErro\');focaCampoErro(\'qtjobporhor24\',\'frmParametrosGerais\');',false);       
		}
		
	}
?>