<?
	//************************************************************************//
	//*** Fonte: utils.php                                     	            ***//
	//*** Autor: Maykon D. Granemann                                       	***//
	//*** Data : Agosto/2018                  Última Alteração: 27/08/2018 	***//
	//***                                                                  	***//
	//*** Objetivo  : Funções auxiliam na rotina aditiv                   	***//
	//***                    	                                           	***//
	//***                                                                  	***//	 
	//*** Alterações: 													   	***//
	//***																	***//
	//***                                                                  	***//
	//***																	***//
	//***																   	***//
	//***																	***//
	//*************************************************************************//
?>
<?
    /***********************************   Geral  *******************************/
    function buscaParametrosRequisicao($arrayParametros)
    {
        $arrayParametrosValores = array();
        
        foreach($arrayParametros as $parametro)
        {            
            $valor = buscaParametroRequisicaoPost($parametro);            
            $arrayParametrosValores[] = array("nome" => $parametro,"valor" => $valor);
        }
        return $arrayParametrosValores;
    }
    function buscaParametroRequisicaoPost($nomeParametro)
    {
        $valorParametro = (isset($_POST[$nomeParametro]))   ? $_POST[$nomeParametro]   : 0  ;
        return $valorParametro;
    }

    function montaXmlDados($arrayParametrosValores)
    {
        $xmlDados  = "";
        $xmlDados .= "<Root>";
        $xmlDados .= " <Dados>";
        foreach($arrayParametrosValores as $parametro)
        {            
            $xmlDados .= "  <".$parametro["nome"].">" .$parametro["valor"]. "</".$parametro["nome"].">";            
        }
        $xmlDados .= " </Dados>";
        $xmlDados .= "</Root>";
        
        return $xmlDados;
    }
    function enviaXmlFuncaoBanco($xmlDados, $nomeTela, $nomeFuncao)
    { 
        global $glbvars;
        $xmlResult = mensageria(
                                    $xmlDados
                                    ,$nomeTela
                                    ,$nomeFuncao
                                    ,$glbvars["cdcooper"]
                                    ,$glbvars["cdagenci"]
                                    ,$glbvars["nrdcaixa"]
                                    ,$glbvars["idorigem"]
                                    ,$glbvars["cdoperad"]
                                    ,"</Root>"
                                );
        return $xmlResult;
    }
    function processaXmlRetornado($xmlResult)
    {        
        $xmlObject = getObjectXML($xmlResult);
         $dom = new DOMDocument;
        $dom->preserveWhiteSpace = FALSE;
        $dom->loadXML($resultXml);
        $dom->save('1v.xml');
        return $xmlObject;
    }
    function processaRetornoErro($xmlObject, $xmlObject)
    {        
        if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') 
        {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
            if ($msgErro == '') 
            {
                $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            throw new Exception(utf8ToHtml($msgErro));            
        }
    }

    function validaTagPrincipalRetornoXml($xmlObject, $tagString)
    {
        $tagPrincipalIgual = false;
        $tagPrincipal = strtoupper($xmlObject->roottag->tags[0]->name);
        $tagString = strtoupper($tagString);

        if($tagPrincipal  == $tagString)
        {
            $tagPrincipalIgual = true;
        }
        return $tagPrincipalIgual;
    }
    function executa()
    {
        global $nomeTela, $nomeFuncaoBanco, $parametrosRequisicao, $tagPrincipal, $xmlObject;
        try{
            $parametrosValoresRequisicao  = buscaParametrosRequisicao($parametrosRequisicao);
            $xmlDados = montaXmlDados($parametrosValoresRequisicao);    
            $xmlResult = enviaXmlFuncaoBanco($xmlDados, $nomeTela , $nomeFuncaoBanco);   
            $xmlObject = processaXmlRetornado($xmlResult);
        
            processaRetornoErro($xmlObject, $xmlObject);
            return validaTagPrincipalRetornoXml($xmlObject, $tagPrincipal);
        }catch(Exception $ex)
        {            
            throw $ex;
        }               
    }
    function respostaJson($tipo, $msg, $cd)
    {
        $arrayRetorno = "";
        $mensagem = array('msg' => $msg, 'code' => $cd);
        if($tipo==1)
        {
            $arrayRetorno = array('success' => $mensagem);
        }else if($tipo==2)
        {
            $arrayRetorno = array('error' => $mensagem);
        }
        return json_encode($arrayRetorno);
    }
    
    /************************************  Aditiv  ******************************/


    /*************************   Interveniente Garantidor  **********************/
    function formataTipoPessoaInterveniente($doc)
    { 
        $doc = trim($doc);
        $tipoPessoa = verificaTipoPessoa($doc);        
        if($tipoPessoa==1)
        {
            $doc = mascaraCpf($doc);
        }else if($tipoPessoa == 2)
        {
            $doc = mascaraCnpj($doc);
            echo "<script>$(function(){ tipoPessoa=2; ajustaParaPessoaJuridica();});</script>";
        }	
        return $doc;
    }
	
	/************************* Atenda Empréstimo - BENS Alienados **********************/
	function removeAcentos($string) {
		return preg_replace(array("/(á|à|ã|â|ä)/","/(Á|À|Ã|Â|Ä)/","/(é|è|ê|ë)/","/(É|È|Ê|Ë)/","/(í|ì|î|ï)/","/(Í|Ì|Î|Ï)/","/(ó|ò|õ|ô|ö)/","/(Ó|Ò|Õ|Ô|Ö)/","/(ú|ù|û|ü)/","/(Ú|Ù|Û|Ü)/","/(ñ)/","/(Ñ)/"),explode(" ","a A e E i I o O u U n N"),$string);
	}
    
?>