<?
 session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");	
	require_once('../../class/xmlfile.php');
   
     $nracordo = $_POST['nracordo'] == '' ? 0 : $_POST['nracordo'];
	 $nrctremp = $_POST['nrctremp'] == '' ? 0 : $_POST['nrctremp'];
	 $cdcooper = $_POST['cdcooper'] == '' ? 0 : $_POST['cdcooper'];
     $operacao = $_POST['operacao'] == '' ? 0 : $_POST['operacao'];

     
	 
	//Monta o xml de requisicao
		if($operacao == ""){
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Dados>";			
			$xml .= "    <nracordo>".$nracordo."</nracordo>";
			$xml .= "    <cdcooper>".$cdcooper."</cdcooper>"; 
			$xml .= "    <vlemprst>".$vlemprst."</vlemprst>";
			$xml .= "  </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "TELA_ATACOR", "BUSCA_CONTRATOS_LC100", $glbvars["nracordo"], $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
			$xmlObjeto = getObjectXML($xmlResult);
					
	 	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	 		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
		}
        $contrato_valido = getByTagName($xmlObjeto->roottag->tags[0]->tags, 'valido');
       
        if($contrato_valido == "N"){
            exibirErro('error',"Contrato Invalido.",'Alerta - Ayllos',"",false); 
        }			

	}else{				
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Dados>";
			$xml .= "    <valido>S</valido>";
			$xml .= "  </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml,"TELA_ATACOR", "VALIDA_CONTRATO_LC100", $glbvars["nracordo"], $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObj = getObjectXML($xmlResult);

			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
			}
			echo "<script>";
			echo "showError('inform','Acordo salvo com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divUsoGenerico\'),divRotina);');";		
			echo "</script>";
		}				

	?>

    