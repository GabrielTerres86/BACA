<?php 

	/******************************************************************
	  Fonte: gerar_devolucao_capital_apos_ago.php                               
	  Autor: Jonata                                                     
	  Data : Julho/2017                 Ultima Alteracao:  
	                                                                   
	  Objetivo  : Script para gerenciar a op��o "G" da tela MATRIC
	                                                                   	 
	  Alteracoes: 													   
	                                         						   
	************************************************************************/
	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permiss�es do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"G")) <> '') {

        exibirErro('error',$msgError,'Alerta - Aimaro','',false);
		
    }
		
	// Se parametros necessarios nao foram informados
	if (!isset($_POST["camposPc"]) || !isset($_POST["dadosPrc"])) {
		exibirErro('error',"Par&acirc;metros incorretos.",'Alerta - Aimaro','',false);
	}	

	$camposPc = $_POST["camposPc"];
	$dadosPrc = $_POST["dadosPrc"];
			
	if((count($camposPc) == 0) || (count($dadosPrc) == 0)){
		exibirErro('error',"Conta(s) n&atilde;o encontrada(s).",'Alerta - Aimaro','',false);

	}	
		
	// Monta o xml de requisi��o
    $xml   = "";
    $xml  .= "<Root>";
    $xml  .= "  <Dados>";
    $xml  .= retornaXmlFilhos( $camposPc, $dadosPrc, 'Reverter', 'Itens');
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0003", "DEV_CAPITAL_APOS_AGO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra cr�tica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;

		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];

        if(empty ($nmdcampo)){
            $nmdcampo = "opcao";
        }

        exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','controlaFoco(\''.$nmdcampo.'\');',false);

    }

    exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Aimaro','controlaVoltar();', false);

	
	
?>