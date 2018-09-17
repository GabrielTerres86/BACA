<?php
	/*!
	 * FONTE        : manter_rotina_solicitar.php                          Última alteração: 29/02/2016
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 24/09/2015
	 * OBJETIVO     : Rotina para realizar a solicitação de arquivos via MQ ao SICREDI
	 * --------------
	 * ALTERAÇÕES   : 16/10/2015 - Ajustes para liberação (Adriano).

					  29/02/2016 - Ajuste para enviar o parâmetro nmdatela pois não está sendo
					               possível gerar o relatório. A rotina do oracle está tentando
								   encontrar o registro crapprg com base no parâmetro cdprogra 
								   e não o encontra, pois ele é gravado com o nome da tela.
								   (Adriano - SD 409943)
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"S")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcopaux = isset($_POST["cdcopaux"]) ? $_POST["cdcopaux"] : 0;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcopaux>".$cdcopaux."</cdcopaux>";
	$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PRCINS", "SOLICITAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','liberaAcaoSolicitar();',false);
				
	} 
	
	echo "strHTML  = '<div class=\"divRegistros\">';";
	echo "strHTML += '  <table>';";
	echo "strHTML += '     <thead>';";
	echo "strHTML += '       <tr>';";
	echo "strHTML += '          <th>Cooperativa</th>';";
	echo "strHTML += '		    <th>Mensagem</th>';";
	echo "strHTML += '	   </tr>';";
	echo "strHTML += '     </thead>';";
	echo "strHTML += '     <tbody>';";		
		
	foreach($xmlObj->roottag->tags[0]->tags as $processo){  
		
		echo "strHTML += '<tr>';";	
		echo "strHTML += '<td><span>".getByTagName($processo->tags,'dscooper')."</span>".getByTagName($processo->tags,'dscooper')."</td>';";
		echo "strHTML += '<td><span>".getByTagName($processo->tags,'dsmensag')."</span>".getByTagName($processo->tags,'dsmensag')."</td>';";
		echo "strHTML += '</tr>';";
		
	}
	
	echo "strHTML += '    </tbody>';";
	echo "strHTML += '  </table>';";
	echo "strHTML += '</div>';";
	echo "strHTML += '<div id=\"divRegistrosRodape\" class=\"divRegistrosRodape\">';";
	echo "strHTML += '   <table>';";	
	echo "strHTML += '     <tr>';";
	echo "strHTML += '        <td>';";
	echo "strHTML += '		  </td>';";
	echo "strHTML += '	      <td>';";
	echo "strHTML += '        </td>';";
	echo "strHTML += '        <td>';";
	echo "strHTML += '        </td>';";
	echo "strHTML += '     </tr>';";
	echo "strHTML += '   </table>';";
	echo "strHTML += '</div>';";
	
	echo "$('#divSolicitarResumo','#frmSolicitar').html(strHTML);";
	echo "formataTabelaSolicitar();";						
	echo "$('#divSolicitarResumo','#frmSolicitar').css('display','block');"; 
	echo "$('#fsetSolicitarResumo','#frmSolicitar').css('display','block');";
	echo "$('#btConcluir','#divBotoes').css({'display':'none'});";
		
?>