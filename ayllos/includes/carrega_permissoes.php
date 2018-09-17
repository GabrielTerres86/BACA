<?php 

	/**************************************************************************
	      Fonte: carrega_permissoes.php                                  
	      Autor: David                                                  
	      Data : Agosto/2007                  Última Alteração: 14/10/2015 
	                                                                 
	      Objetivo  : Retornar opções e rotinas de tela                
	                                                                	 
	      Alterações: 22/10/2010 - Incluir novo parametro para a funcao    
	                               getDataXML (David).    

					  14/10/2015 - Reformulacao cadastral (Gabriel-RKAM).					

  					  11/07/2016	 - Correcao do erro de inexistencia do indice 0	dentro da TAG 
										   de retorno do XML. SD 479874 (Carlos R.) 					  
	**************************************************************************/
	
	$nmdatela = isset($_POST["nmdatela"]) ? $_POST["nmdatela"] : $glbvars["nmdatela"];
	$nmrotina = isset($_POST["nmrotina"]) ? $_POST["nmrotina"] : $glbvars["nmrotina"];
	$executandoProdutos = isset($_POST["executandoProdutos"]) ? $_POST["executandoProdutos"] : 'false';
	
	// Monta o xml de requisição
	$xmlGetPermis  = "";
	$xmlGetPermis .= "<Root>";
	$xmlGetPermis .= "	<Cabecalho>";
	$xmlGetPermis .= "		<Bo>b1wgen0000.p</Bo>";
	$xmlGetPermis .= "		<Proc>obtem_permissao</Proc>";
	$xmlGetPermis .= "	</Cabecalho>";
	$xmlGetPermis .= "	<Dados>";
	$xmlGetPermis .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetPermis .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetPermis .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetPermis .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetPermis .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetPermis .= "		<idsistem>".$glbvars["idsistem"]."</idsistem>";
	$xmlGetPermis .= "		<nmdatela>".$nmdatela."</nmdatela>";
	$xmlGetPermis .= "		<nmrotina>".$nmrotina."</nmrotina>";
	$xmlGetPermis .= "		<cddopcao></cddopcao>";
	$xmlGetPermis .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetPermis .= "	</Dados>";
	$xmlGetPermis .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPermis,false);	
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPermis = getObjectXML($xmlResult);

	// Se BO retornou algum erro, redireciona para home
	if (strtoupper($xmlObjPermis->roottag->tags[0]->name) == "ERRO") {
		$msgError = $xmlObjPermis->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($glbvars["redirect"] == "html") {
			redirecionaErro($glbvars["redirect"],$UrlSite."principal.php","_self",$msgError);
		} elseif ($glbvars["redirect"] == "script_ajax") {
			echo 'hideMsgAguardo();';
			echo 'showError("error","'.addslashes($msgError).'","Alerta - Permiss&otilde;es","");';
		} elseif ($glbvars["redirect"] == "html_ajax") {
			
			if ($nmdatela == 'ATENDA' && $executandoProdutos == 'true') {
				$metodo = 'encerraRotina();';
			}	
			else { 
				$metodo = '';
			}
			
			echo '<script type="text/javascript">hideMsgAguardo();showError("error","'.addslashes($msgError).'","Alerta - Permiss&otilde;es","' . $metodo . '");</script>';
		}
		
		exit();
	} else {
		// Armazenar nome da tela e rotina na sessão
		setVarSession("nmdatela",$nmdatela);
		setVarSession("nmrotina",$nmrotina);		
		
		// Cria novo array para armazenar as opções da tela
		$opcoesTela = array();

		// Leitura do objeto $xmlObjPermis para atribuir opções da tela ao array (node <Opcoes> do XML)
		for ($i = 0; $i < count($xmlObjPermis->roottag->tags[0]->tags); $i++) {
			$opcoesTela[$i] = $xmlObjPermis->roottag->tags[0]->tags[$i]->tags[0]->cdata;					
		}
		 
		// Cria novo array para armazenar as rotinas da tela
		$rotinasTela = array();
		
		// Leitura do objeto $xmlObjPermis para atribuir rotinas da tela ao array (node <Rotinas> do XML)
		for ($i = 0; $i < count($xmlObjPermis->roottag->tags[1]->tags); $i++) {			
			$rotinasTela[$i] = $xmlObjPermis->roottag->tags[1]->tags[$i]->tags[0]->cdata;					
		}


        // Monta o xml de requisição para incluir registro na CRAPLGT - LOG DE ACESSO A TELAS
        $xmlIncluir  = "";
        $xmlIncluir .= "<Root>";
        $xmlIncluir .= "	<Cabecalho>";
        $xmlIncluir .= "		<Bo>b1wgen0013.p</Bo>";
        $xmlIncluir .= "		<Proc>registra-log-acesso-telas</Proc>";
        $xmlIncluir .= "	</Cabecalho>";
        $xmlIncluir .= "	<Dados>";
        $xmlIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
        $xmlIncluir .= "		<dsdatela>".$glbvars["nmdatela"]."</dsdatela>";    
        $xmlIncluir .= "		<idorigem>2</idorigem>";
        $xmlIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
        $xmlIncluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
        $xmlIncluir .= "	</Dados>";
        $xmlIncluir .= "</Root>";
            
        // Executa script para envio do XML
        $xmlResult2 = getDataXML($xmlIncluir);
            
        // Cria objeto para classe de tratamento de XML
        $xmlObjRegistro = getObjectXML($xmlResult2);
            
		// armazena o indice de retorno de erro caso ele exista
		$msgErroPermi = isset($xmlObjRegistro->roottag->tags[0]) ? strtoupper($xmlObjRegistro->roottag->tags[0]) : '';

        // Se ocorrer um erro, mostra crítica
        if ($msgErroPermi == "ERRO") {
            exibirErro($xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata);
        }
	}

?>