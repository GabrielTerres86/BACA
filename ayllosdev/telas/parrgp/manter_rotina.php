<?php
/*!
 * FONTE        : manter_rotina.php                    Última alteração: 23/06/2017
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Rotina para alterar/incluir/excluir informações da tela PARRGP
 * --------------
 * ALTERAÇÕES   : 15/06/2017 - Retirado/incluido a validação de campos para verificar se são obrigatórios o envio (Jonata - RKAM).
 *
 *                23/06/2017 - Ajuste para retirar a obrigatoriedade do campo IDCARACT_ESPECIAL (Jonata - RKAM).
 *
 */
?>

<?php

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Carrega permissões do operador
    require_once('../../includes/carrega_permissoes.php');

    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }

	$idproduto                   =  (isset($_POST["idproduto"])) ? $_POST["idproduto"] : 0;
	$dsproduto                   =  (isset($_POST["dsproduto"])) ? $_POST["dsproduto"] : '';
	$tpdestino                   =  (isset($_POST["tpdestino"])) ? $_POST["tpdestino"] : '';
	$tparquivo                   =  (isset($_POST["tparquivo"])) ? $_POST["tparquivo"] : '';
	$idgarantia                  =  (isset($_POST["idgarantia"])) ? $_POST["idgarantia"] : 0;
	$idmodalidade			     =  (isset($_POST["idmodalidade"])) ? $_POST["idmodalidade"] : 0;
	$idconta_cosif               =  (isset($_POST["idconta_cosif"])) ? $_POST["idconta_cosif"] : 0;
	$idorigem_recurso            =  (isset($_POST["idorigem_recurso"])) ? $_POST["idorigem_recurso"] : 0;
	$idindexador                 =  (isset($_POST["idindexador"])) ? $_POST["idindexador"] : 0;
	$perindexador                =  (isset($_POST["perindexador"])) ? $_POST["perindexador"] : 0;
	$vltaxa_juros                =  (isset($_POST["vltaxa_juros"])) ? $_POST["vltaxa_juros"] : 0;
	$cdclassifica_operacao       =  (isset($_POST["cdclassifica_operacao"])) ? $_POST["cdclassifica_operacao"] : 0;
	$idvariacao_cambial          =  (isset($_POST["idvariacao_cambial"])) ? $_POST["idvariacao_cambial"] : 0;
	$idorigem_cep                =  (isset($_POST["idorigem_cep"])) ? $_POST["idorigem_cep"] : '';
	$idnat_operacao              =  (isset($_POST["idnat_operacao"])) ? $_POST["idnat_operacao"] : 0;
	$idcaract_especial           =  (isset($_POST["idcaract_especial"])) ? $_POST["idcaract_especial"] : 0;
	$flpermite_saida_operacao    =  (isset($_POST["flpermite_saida_operacao"])) ? $_POST["flpermite_saida_operacao"] : 0;
	$flpermite_fluxo_financeiro  =  (isset($_POST["flpermite_fluxo_financeiro"])) ? $_POST["flpermite_fluxo_financeiro"] : 0;
	$flreaprov_mensal            =  (isset($_POST["flreaprov_mensal"])) ? $_POST["flreaprov_mensal"] : 0;
	
	$dsproduto = str_replace('"','',str_replace(">","",str_replace("<","",retiraAcentos(removeCaracteresInvalidos(utf8_decode($dsproduto))))));
	
    validaDados();
  
	$xmlManterRotina  = "";
	$xmlManterRotina .= "<Root>";
	$xmlManterRotina .= "   <Dados>";
	$xmlManterRotina .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlManterRotina .= "	   <idproduto>".$idproduto."</idproduto>";
	$xmlManterRotina .= "	   <dsproduto>".$dsproduto."</dsproduto>";
	$xmlManterRotina .= "	   <tpdestino>".$tpdestino."</tpdestino>";
	$xmlManterRotina .= "	   <tparquivo>".$tparquivo."</tparquivo>";
	$xmlManterRotina .= "	   <idgarantia>".$idgarantia."</idgarantia>";
	$xmlManterRotina .= "	   <idmodalidade>".$idmodalidade."</idmodalidade>";
	$xmlManterRotina .= "	   <idconta_cosif>".$idconta_cosif."</idconta_cosif>";
	$xmlManterRotina .= "	   <idorigem_recurso>".$idorigem_recurso."</idorigem_recurso>";
	$xmlManterRotina .= "	   <idindexador>".$idindexador."</idindexador>";
	$xmlManterRotina .= "	   <perindexador>".$perindexador."</perindexador>";
	$xmlManterRotina .= "	   <vltaxa_juros>".$vltaxa_juros."</vltaxa_juros>";
	$xmlManterRotina .= "	   <cdclassifica_operacao>".$cdclassifica_operacao."</cdclassifica_operacao>";
	$xmlManterRotina .= "	   <idvariacao_cambial>".$idvariacao_cambial."</idvariacao_cambial>";
	$xmlManterRotina .= "	   <idorigem_cep>".$idorigem_cep."</idorigem_cep>";
	$xmlManterRotina .= "	   <idnat_operacao>".$idnat_operacao."</idnat_operacao>";
	$xmlManterRotina .= "	   <idcaract_especial>".$idcaract_especial."</idcaract_especial>";
	$xmlManterRotina .= "	   <flpermite_saida_operacao>".$flpermite_saida_operacao."</flpermite_saida_operacao>";
	$xmlManterRotina .= "	   <flpermite_fluxo_financeiro>".$flpermite_fluxo_financeiro."</flpermite_fluxo_financeiro>";
	$xmlManterRotina .= "	   <flreaprov_mensal>".$flreaprov_mensal."</flreaprov_mensal>";
	$xmlManterRotina .= "   </Dados>";
	$xmlManterRotina .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlManterRotina, "TELA_PARRGP", "MANTERROTINA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjManterRotina = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjManterRotina->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjManterRotina->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjManterRotina->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cddopcao";
		}
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#frmDetalhes\').removeClass(\'campoErro\');unblockBackground(); $(\'#'.$nmdcampo.'\',\'#frmDetalhes\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmDetalhes\');',false);		
							
	}else if (strtoupper($xmlObjManterRotina->roottag->tags[0]->name) == "MENSAGEM") {
	
		$msgErro  = $xmlObjManterRotina->roottag->tags[0]->tags[0]->cdata;
				 
		exibirErro('inform',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
							
	}      
		
    function validaDados(){
		
		//ID do produto
        if (  $GLOBALS["cddopcao"] != 'I' && $GLOBALS["idproduto"] == 0){
            exibirErro('error','C&oacute;digo do produto inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'dsproduto\',\'frmDetalhes\');',false);
        }

        //Descrição do produto
        if ( $GLOBALS["dsproduto"] == ''){
            exibirErro('error','A descri&ccedil;&atilde;o deve ser informada.','Alerta - Ayllos','focaCampoErro(\'dsproduto\',\'frmDetalhes\');',false);
        }
		
        //Tipo do detino
        if ( $GLOBALS["tpdestino"] != 'C' && $GLOBALS["tpdestino"] != 'S' && $GLOBALS["tpdestino"] != 'A'){
            exibirErro('error','Tipo de destino inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'tpdestino\',\'frmDetalhes\');',false);
        }

        //Tipo do arquivo
        if ( $GLOBALS["tparquivo"] != 'Nao' && 
		     $GLOBALS["tparquivo"] != 'Cartao_Bancoob' &&
			 $GLOBALS["tparquivo"] != 'Cartao_BB' &&
			 $GLOBALS["tparquivo"] != 'Cartao_BNDES_BRDE' &&
			 $GLOBALS["tparquivo"] != 'Inovacred_BRDE' &&
			 $GLOBALS["tparquivo"] != 'Finame_BRDE'){
            exibirErro('error','Tpo do arquivo inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'tparquivo\',\'frmDetalhes\');',false);
        }

		$pos = strpos($GLOBALS["tparquivo"], "BRDE");
		
		if($pos === false){
			
			//Origem do recurso
			if ( $GLOBALS["idorigem_recurso"] == 0){
				exibirErro('error','Origem do recurso inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'idorigem_recurso\', \'frmDetalhes\');',false);
			}
			
			//Indexador do produto
			if ( $GLOBALS["idindexador"] == 0){
				exibirErro('error','Indexador inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'idindexador\', \'frmDetalhes\');',false);
			}
			
			//Natureza de operação
			if ( $GLOBALS["idnat_operacao"] == 0){
				exibirErro('error','Natureza de opera&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'idnat_operacao\', \'frmDetalhes\');',false);
			}
						
		}
		
        //ID da garantia
        if ( $GLOBALS["idgarantia"] == 0){
            exibirErro('error','C&oacute;digo da garantia inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'idgarantia\',\'frmDetalhes\');',false);
        }

        //ID da modalidade
        if ( $GLOBALS["idmodalidade"] == 0){
            exibirErro('error','C&oacute;digo da modalidade inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'idmodalidade\',\'frmDetalhes\');',false);
        }

        //Conta COSIF
        if ( $GLOBALS["idconta_cosif"] == 0){
            exibirErro('error','Conta COSIF inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'idconta_cosif\',\'frmDetalhes\');',false);
        }
			
		//ID da variação cambial
        if ( $GLOBALS["idvariacao_cambial"] == ''){
            exibirErro('error','C&oacute;digo da varia&ccedil;&atilde;o cambial inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'idvariacao_cambial\', \'frmDetalhes\');',false);
        }
			
		//Origem do CEP
        if ( $GLOBALS["idorigem_cep"] == ''){
			exibirErro('error','Informe o telefone do respons&aacute;vel.','Alerta - Ayllos','focaCampoErro(\'idorigem_cep\', \'divTabela\');',false);
		}
			
		//Saida de operação
        if ( $GLOBALS["flpermite_saida_operacao"] == ''){
            exibirErro('error','Permite sa&iacute;da n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'flpermite_saida_operacao\', \'frmDetalhes\');',false);
        }
		
		//Saida de operação
        if ( $GLOBALS["flpermite_fluxo_financeiro"] == ''){
            exibirErro('error','Permite fluxo financeiro n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'flpermite_fluxo_financeiro\', \'frmDetalhes\');',false);
        }
		
		//Saida de operação
        if ( $GLOBALS["flreaprov_mensal"] == ''){
            exibirErro('error','Reaproveitamento mensal n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'flreaprov_mensal\', \'frmDetalhes\');',false);
        }
		
		//Classificação da operação
        if ( $GLOBALS["cdclassifica_operacao"] == ''){
            exibirErro('error','Classifica&ccedil;atilde;o n&atilde;o informada.','Alerta - Ayllos','focaCampoErro(\'cdclassifica_operacao\', \'frmDetalhes\');',false);
        }
		
    }

 ?>
