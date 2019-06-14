<?php
/*!
 * FONTE        : alterar_movimento.php                    Última alteração: 25/06/2017
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Rotina para alteração de movimentos da tela MOVRGP
 * --------------
 * ALTERAÇÕES   :  01/06/2017 - Ajuste para retirar validação do valor pencentual, poderá ser enviado valor zerado
                                (Jonata - RKAM).
								
				   25/06/2017 - Ajuste para retirar a validação do saldo pendente ( Jonata - RKAM).
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

	$cdcopsel                 = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;
	$dtrefere                 = (isset($_POST["dtrefere"])) ? $_POST["dtrefere"] : '';
	$idmovto_risco            = (isset($_POST["idmovto_risco"])) ? $_POST["idmovto_risco"] : 0;
	$idproduto                = (isset($_POST["idproduto"])) ? $_POST["idproduto"] : 0;              
	$nrcpfcgc                 = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;               
	$nrdconta                 = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;               
	$nrctremp                 = (isset($_POST["nrctremp"])) ? $_POST["nrctremp"] : 0;               
	$idgarantia               = (isset($_POST["idgarantia"])) ? $_POST["idgarantia"] : 0;             
	$idorigem_recurso         = (isset($_POST["idorigem_recurso"])) ? $_POST["idorigem_recurso"] : 0;       
	$idindexador              = (isset($_POST["idindexador"])) ? $_POST["idindexador"] : 0;        
	$perindexador             = (isset($_POST["perindexador"])) ? $_POST["perindexador"] : 0;         
	$vltaxa_juros             = (isset($_POST["vltaxa_juros"])) ? $_POST["vltaxa_juros"] : 0;       
	$dtlib_operacao           = (isset($_POST["dtlib_operacao"])) ? $_POST["dtlib_operacao"] : '';       
	$vloperacao               = (isset($_POST["vloperacao"])) ? $_POST["vloperacao"] : 0;      
	$idnat_operacao           = (isset($_POST["idnat_operacao"])) ? $_POST["idnat_operacao"] : 0;     
	$dtvenc_operacao     	  = (isset($_POST["dtvenc_operacao"])) ? $_POST["dtvenc_operacao"] : '';    
	$cdclassifica_operacao    = (isset($_POST["cdclassifica_operacao"])) ? $_POST["cdclassifica_operacao"] : ''; 
	$qtdparcelas              = (isset($_POST["qtdparcelas"])) ? $_POST["qtdparcelas"] : 0; 
	$vlparcela                = (isset($_POST["vlparcela"])) ? $_POST["vlparcela"] : 0;
	$dtproxima_parcela        = (isset($_POST["dtproxima_parcela"])) ? $_POST["dtproxima_parcela"] : '';
	$vlsaldo_pendente         = (isset($_POST["vlsaldo_pendente"])) ? $_POST["vlsaldo_pendente"] : 0;
	$flsaida_operacao         = (isset($_POST["flsaida_operacao"])) ? $_POST["flsaida_operacao"] : 0; 
	
	validaDados();
  
	$xmlAlterar  = "";
	$xmlAlterar .= "<Root>";
	$xmlAlterar .= "   <Dados>";
	$xmlAlterar .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlAlterar .= "	   <cdcopsel>".$cdcopsel."</cdcopsel>";
	$xmlAlterar .= "	   <dtrefere>".$dtrefere."</dtrefere>";
	$xmlAlterar .= "	   <idmovto_risco>".$idmovto_risco."</idmovto_risco>";
	$xmlAlterar .= "	   <idproduto>".$idproduto."</idproduto>";
	$xmlAlterar .= "	   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlAlterar .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlAlterar .= "	   <nrctremp>".$nrctremp."</nrctremp>";
	$xmlAlterar .= "	   <idgarantia>".$idgarantia."</idgarantia>";
	$xmlAlterar .= "	   <idorigem_recurso>".$idorigem_recurso."</idorigem_recurso>";
	$xmlAlterar .= "	   <idindexador>".$idindexador."</idindexador>";
	$xmlAlterar .= "	   <perindexador>".$perindexador."</perindexador>";
	$xmlAlterar .= "	   <vltaxa_juros>".$vltaxa_juros."</vltaxa_juros>";
	$xmlAlterar .= "	   <dtlib_operacao>".$dtlib_operacao."</dtlib_operacao>";
	$xmlAlterar .= "	   <vloperacao>".$vloperacao."</vloperacao>";
	$xmlAlterar .= "	   <idnat_operacao>".$idnat_operacao."</idnat_operacao>";
	$xmlAlterar .= "	   <dtvenc_operacao>".$dtvenc_operacao."</dtvenc_operacao>";
	$xmlAlterar .= "	   <cdclassifica_operacao>".$cdclassifica_operacao."</cdclassifica_operacao>";
	$xmlAlterar .= "	   <qtdparcelas>".$qtdparcelas."</qtdparcelas>";
	$xmlAlterar .= "	   <vlparcela>".$vlparcela."</vlparcela>";
	$xmlAlterar .= "	   <dtproxima_parcela>".$dtproxima_parcela."</dtproxima_parcela>";
	$xmlAlterar .= "	   <vlsaldo_pendente>".$vlsaldo_pendente."</vlsaldo_pendente>";
	$xmlAlterar .= "	   <flsaida_operacao>".$flsaida_operacao."</flsaida_operacao>";
	$xmlAlterar .= "   </Dados>";
	$xmlAlterar .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlAlterar, "TELA_MOVRGP", "ALTERARMVTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjAlterar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjAlterar->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrcpfcgc";
		}
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\''.$nmdcampo.'\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
							
	}    

	exibirErro('inform','Movimento alterado com sucesso.','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));carregaMovimentos(\'1\',\'30\');',false);		
	
		
    function validaDados(){
		
		//Código da cooperativa selecionado
        if (  $GLOBALS["cdcopsel"] == 0 ){
            exibirErro('error','C&oacute;digo da cooperativa inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'nrcpfcgc\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Data de referência
        if (  $GLOBALS["dtrefere"] == '' ){
            exibirErro('error','Data de refer&ecirc;ncia inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'nrcpfcgc\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		
		//Código do movimento
        if (  $GLOBALS["idmovto_risco"] == 0 ){
            exibirErro('error','C&oacute;digo do movimento inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'nrcpfcgc\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Código do produto
        if (  $GLOBALS["idproduto"] == 0 ){
            exibirErro('error','C&oacute;digo do produto inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'nrcpfcgc\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//CPF/CNPJ
        if (  $GLOBALS["nrcpfcgc"] == 0 ){
            exibirErro('error','CPF/CNPJ inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'nrcpfcgc\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }

		//Número da conta
        if (  $GLOBALS["nrdconta"] == 0 ){
            exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'nrdconta\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Número do contrato
        if (  $GLOBALS["nrctremp"] == 0 ){
            exibirErro('error','Contrato inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'nrctremp\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Código da garantia
        if (  $GLOBALS["idgarantia"] == 0 ){
            exibirErro('error','C&oacute;digo da garantia inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'idgarantia\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Código de origem do recurso
        if (  $GLOBALS["idorigem_recurso"] == 0 ){
            exibirErro('error','C&oacute;digo de origem do recurso inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'idorigem_recurso\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Código de indexador
        if (  $GLOBALS["idindexador"] == 0 ){
            exibirErro('error','C&oacute;digo do indexador inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'idindexador\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Valor da taxa de juros
        if (  $GLOBALS["vltaxa_juros"] == 0 ){
            exibirErro('error','Valor da taxa de juros inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'vltaxa_juros\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Data de liberação da operação
        if (  $GLOBALS["dtlib_operacao"] == '' ){
            exibirErro('error','Data de libera&ccedil;&atilde;o da opera&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dtlib_operacao\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Valor da operação
        if (  $GLOBALS["vloperacao"] == 0 ){
            exibirErro('error','Valor da opera&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'vloperacao\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Código de natureza da operação
        if (  $GLOBALS["idnat_operacao"] == 0){
            exibirErro('error','C&oacute;digo da natureza de opera&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'idnat_operacao\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Data de vencimento da operação
        if (  $GLOBALS["dtvenc_operacao"] == '' ){
            exibirErro('error','Data de vencimento da opera&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dtvenc_operacao\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Classificação da operação
        if (  $GLOBALS["cdclassifica_operacao"] == '' ){
            exibirErro('error','Classifica&ccedil;&atilde;o da opera&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'cdclassifica_operacao\',\'frmDetalhes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }		
			
	}

 ?>
