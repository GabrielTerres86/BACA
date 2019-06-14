<?php 

	//************************************************************************//
	//*** Fonte: param_session.php                                         ***//
	//*** Autor: JDB AMcom                                                 ***//
	//*** Data : Marco/2019                   Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar parametros (CRAPPRM)                          ***//
	//*** e inserir na session ($glbvars)                                  ***//	 
    //***                                                                  ***//
	//************************************************************************//
	
	session_start();
		
	//Valida se a cooperativa pode ter acesso a consignados
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		
		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"VAL_COOPER_CONSIGNADO",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");
			
		$xmlObj = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			setVarSession("VAL_COOPER_CONSIGNADO",'N');
		}else{
			if ($xmlObj->roottag->tags[0]->cdata == 'S'){
				setVarSession("VAL_COOPER_CONSIGNADO",'S');
			}else{
				setVarSession("VAL_COOPER_CONSIGNADO",'N');
			}
			
		}
	//Fim Valida se a cooperativa pode ter acesso a consignados
?>		
