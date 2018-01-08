<?php
/*!
 * FONTE        : verifica_produtos_ativosCRM.php                    Última alteração: 
 * CRIAÇÃO      : Renato Darosci (SUPERO)
 * DATA CRIAÇÃO : Dezembro/2017
 * OBJETIVO     : Rotina para verificar os servicos ativos como na CADMAT
 * --------------
 * ALTERAÇÕES   :   
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

	//$dtdemiss = (isset($_POST["dtdemiss"])) ? $_POST["dtdemiss"] : '';
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	//$cdmotdem = (isset($_POST["cdmotdem"])) ? $_POST["cdmotdem"] : 0;	
	
	validaDados();
	
	// Monta o xml de requisição
	$xmlMatric  = '';
	$xmlMatric .= '<Root>';
	$xmlMatric .= '	<Cabecalho>';
	$xmlMatric .= '		<Bo>b1wgen0052.p</Bo>';
	$xmlMatric .= '		<Proc>Produtos_Servicos_Ativos</Proc>';
	$xmlMatric .= '	</Cabecalho>';
	$xmlMatric .= '	<Dados>';
	$xmlMatric .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlMatric .= '		<cdagenci>'.$glbvars['dtdemiss'].'</cdagenci>';
	$xmlMatric .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlMatric .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlMatric .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlMatric .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlMatric .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlMatric .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlMatric .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xmlMatric .= '		<idseqttl>1</idseqttl>';
	$xmlMatric .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xmlMatric .= '	</Dados>';
	$xmlMatric .= '</Root>';
		
	/// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xmlMatric);
	$xmlObjeto 	= getObjectXML($xmlResult);		
	
	$tagsProdServ 	= $xmlObjeto->roottag->tags[0]->tags;
	
	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$operacao = '';
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		$mtdErro  = "showMsgAguardo( 'Aguarde, carregando ...' );setTimeout('controlaVoltar()',1);";		
		
		exibirErro('error',$msgErro,'Alerta - Matric',$mtdErro,false);
	} 
		
	$prodservArray = Array();
				
	//foreach( $tagsProdServ as $registros){
	//	$prodservArray[] = getByTagName($registros->tags,'nmproser');
	//}
	
	if(count($prodservArray) > 0 ){
		$style 	   = "";
		$aux_table = "";
		
		$aux_table = "<table style='border:2px solid gray;background-color:white;'>";
		$aux_table.= "	<tr><td style='background-color:#E8E8E8;height:20px;'>";
		$aux_table.= "		<span style='margin-left:10px;'>Os Produtos/Servi&ccedil;os est&atilde;o ativos na conta:</span>";
		$aux_table.= "	</td></tr>";
		$aux_table.= "	<tr><td>";
		$aux_table.= "		<div style='height:129px;overflow-x:hidden;overflow-y:scroll;width:280px;text-align:left'>";
		$aux_table.= "		<table style='width:100%'>";
		
		foreach($prodservArray as $prodserv) {
			
			if ($style == " style='background-color: #FFFFFF;' ") {
				$style =  " style='background-color: #F0F0F0;' ";
			} else { 
				$style =  " style='background-color: #FFFFFF;' "; 
			}
			$aux_table.= "		<tr ".$style.">";
			$aux_table.= "			<td style='font-weight:bold;'> - ".$prodserv."</td>";
			$aux_table.= "		</tr>";
			
		}
		
		$aux_table.= "		</table>";
		$aux_table.= "		</div>";
		$aux_table.= "		</td>";
		$aux_table.= "	</tr>";
		$aux_table.= "</table>";
		
		exibirMensagens('none',$aux_table,'Notifica&ccedil;&atilde;o - MATRIC','showError(\'inform\',\'Atrav&eacute;s da tela CONTAS, na op&ccedil;&atilde;o Impedimentos de Desligamento, todos os produtos e servi&ccedil;os devem ser cancelados.\',\'Notifica&ccedil;&atilde;o - Ayllos\',\'unblockBackground();\');',false);
		
    }else{	
	
		echo "apresentarDesligamentoCRM();";
		
	}
	
	function validaDados(){
		
		//Número da conta
        if (  $GLOBALS["nrdconta"] == 0 ){
            exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
	}

 ?>
