<?php 

	/******************************************************************
	  Fonte: atualizar_contas_antigas_demitidas.php                               
	  Autor: Jonata                                                     
	  Data : Novembro/2017                 Ultima Alteracao:  
	                                                                   
	  Objetivo  : Script para gerenciar a opção "H" da tela MATRIC
	                                                                   	 
	  Alteracoes:  04/09/2018 - Incluido campo operauto (operador autorizador) na passagem de parametro.
                              (Alcemir - Mout's : SM 364)
	                                         						   
	************************************************************************/
	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"G")) <> '') {

        exibirErro('error',$msgError,'Alerta - Aimaro','',false);
		
    }
		
	// Se parametros necessarios nao foram informados
	if (!isset($_POST["camposPc"]) || !isset($_POST["dadosPrc"]) || !isset($_POST["operauto"])) {  
		exibirErro('error',"Par&acirc;metros incorretos.",'Alerta - Aimaro','',false);
	}	

	$camposPc = $_POST["camposPc"];
	$dadosPrc = $_POST["dadosPrc"];
  $operauto = $_POST["operauto"];
			
	if((count($camposPc) == 0) || (count($dadosPrc) == 0)){
		exibirErro('error',"Conta(s) n&atilde;o encontrada(s).",'Alerta - Aimaro','',false);

	}	
		
	// Monta o xml de requisição
    $xml   = "";
    $xml  .= "<Root>";
    $xml  .= "  <Dados>";
    $xml  .= "   <cdopelib>".$operauto."</cdopelib>";
    $xml  .= retornaXmlFilhos( $camposPc, $dadosPrc, 'Reverter', 'Itens');
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0003", "ATUALIZA_CTA_ANT_DEMITIDAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
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