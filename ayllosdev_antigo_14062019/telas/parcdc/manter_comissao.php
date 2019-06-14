<? 
/*!
 * FONTE        : manter_comissao.php
 * CRIAÇÃO      : Diego Simas         
 * DATA CRIAÇÃO : 01/05/2018
 * OBJETIVO     : Rotina para manter as operações da tela PARCDC
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$retornoAposErro= '';
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$cddopcao       = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;	
	$idcomissao		= (isset($_POST['idcomissao'])) ? $_POST['idcomissao'] : 0  ;	
	$nmcomissao		= (isset($_POST['nmcomissao'])) ? $_POST['nmcomissao'] : '' ;
	$tpvalor		= (isset($_POST['tpvalor'])) ? $_POST['tpvalor'] : 0  ; 	
	$flgativo		= (isset($_POST['flgativo'])) ? $_POST['flgativo'] : 0;
    $nmrotina       = isset($_POST["nmrotina"]) ? $_POST["nmrotina"] : $glbvars["nmrotina"];

    $retornoAposErro = 'focaCampoErro(\'idcomissao\', \'frmComissao\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$nmrotina,$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'I': 
        	// Monta o xml de requisicao
            $xml  = "<Root>";
            $xml .= " <Dados>";
            $xml .= "  <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
            $xml .= "  <idcomissao>".$idcomissao."</idcomissao>";
            $xml .= "  <nmcomissao>".$nmcomissao."</nmcomissao>";
            $xml .= "  <tpcomissao>".$tpvalor."</tpcomissao>";
            $xml .= "  <flgativo>".$flgativo."</flgativo>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            $xmlResult = mensageria($xml, "TELA_PARCDC", "INCLUIR_COMISSAO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObjeto = getObjectXML($xmlResult);

            $comissao = $xmlObjeto->roottag->tags[0]->tags[0]->tags; 
            $idRetorno = getByTagName($comissao, 'idcomcor');
            

            if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {			
                $msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
                if ($msgErro == "") {
                    $msgErro = utf8_decode($xmlObjeto->roottag->tags[0]->cdata);
                }            
                $msgErro = str_replace('"','',str_replace('(','',str_replace(')','',$msgErro)));	
                            
                echo('showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divUsoGenerico\').css(\'z-index\')));")');
                exit();
            }else{
                echo 'showError("inform","Comiss&atilde;o inclu&iacute;da com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';				
                echo "carregaDetalhamento();";	
                echo "$('#idcomissao','#frmComissao').val(".$idRetorno.");";
                exit();
            }

            break;

		case 'A': 

            // Monta o xml de requisicao
            $xml  = "<Root>";
            $xml .= " <Dados>";
            $xml .= "  <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
            $xml .= "  <idcomissao>".$idcomissao."</idcomissao>";
            $xml .= "  <tpcomissao>".$tpvalor."</tpcomissao>";
            $xml .= "  <flgativo>".$flgativo."</flgativo>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            $xmlResult = mensageria($xml, "TELA_PARCDC", "ALTERAR_COMISSAO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObjeto = getObjectXML($xmlResult);

            if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {			
                $msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
                if ($msgErro == "") {
                    $msgErro = utf8_decode($xmlObjeto->roottag->tags[0]->cdata);
                }            
                $msgErro = str_replace('"','',str_replace('(','',str_replace(')','',$msgErro)));	
                            
                echo 'showError("error","'.$msgErro.'","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaCamposInclusao();");';				
                echo "carregaDetalhamento();";	                
                exit();
            }else{
                echo 'showError("inform","Comiss&atilde;o alterada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaCamposInclusao();");';				
                echo "carregaDetalhamento();";	                
                exit();
            }

            break;

		case 'E': 
            
            // Monta o xml de requisicao
            $xml  = "<Root>";
            $xml .= " <Dados>";
            $xml .= "  <idcomissao>".$idcomissao."</idcomissao>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            $xmlResult = mensageria($xml, "TELA_PARCDC", "EXCLUIR_COMISSAO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObjeto = getObjectXML($xmlResult);

            if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {			
                $msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
                if ($msgErro == "") {
                    $msgErro = utf8_decode($xmlObjeto->roottag->tags[0]->cdata);
                }            
                $msgErro = str_replace('"','',str_replace('(','',str_replace(')','',$msgErro)));	
                            
             
	            echo('showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaCamposInclusao()")');
                
				exit();
            }else{
                echo 'showError("inform","Comiss&atilde;o exclu&iacute;da com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaCamposInclusao();");';				
                echo "btnVoltarComissao();";
                exit();
            }

            break;

	}

			
?>
