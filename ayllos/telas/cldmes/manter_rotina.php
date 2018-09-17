<?php
	/*********************************************************************************************
	 Fonte: manter_rotina.php		                                                      
	 Autor: Cristian Filipe                                                               
	 Data : Novembro/2013                                                                 
	 Objetivo  : Rotinas da tela CLDMES		                        Última alteração: 22/12/2014
	 
	 Alterações: 24/11/2014 - Ajustes para liberação (Adriano).
	             22/12/2014 - Adicionar validação para parametro de data (Douglas - Chamado 143945)
	                                                                                       
	**********************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// codigo da opção
    $cddopcao 	 = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {	
		exibirErro('error',$msgError,'Alerta - Ayllos',"",false);
	}	

	if(!isset($_POST['tdtmvtol']) || !validaData($_POST['tdtmvtol'])){
		exibirErro('error','Data invalida','Alerta - Ayllos',"estadoInicial()",false);
	}
	
    $tdtmvtol = (isset($_POST['tdtmvtol'])) ? $_POST['tdtmvtol'] : '' ; 
    $cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : '' ; 
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ; 
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ;     

	$procedure = "";
	
	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'Carrega_creditos'; break;
		case 'F': $procedure = 'Fechamento_diario'; break;
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0174.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>'{$procedure}'</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= '        <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlSetPesquisa .= '        <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlSetPesquisa .= '        <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xmlSetPesquisa .= '        <idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlSetPesquisa .= '        <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlSetPesquisa .= '        <cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';			
	$xmlSetPesquisa .= "        <cdagepac>".$cdagepac."</cdagepac>";	
	$xmlSetPesquisa .= "        <tdtmvtol>".$tdtmvtol."</tdtmvtol>";	
	$xmlSetPesquisa .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xmlSetPesquisa .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa );
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	if($cddopcao == "C"){
	
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
			$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$erros 		= exibirErro('error',$msgErro,'Alerta - Ayllos',"$('#tdtmvtol','#frmInfConsulta').focus();$('#cdagepac','#frmInfConsulta').val('');",false);
			
		} 	
	
		$registros = $xmlObjPesquisa->roottag->tags[0]->tags;	
		$qtregist  = $xmlObjPesquisa->roottag->tags[0]->attributes['QTREGIST'];
		include('tab_movimentacao.php');
		
		?>
		<script type="text/javascript">
		
			$('#btSalvar', '#frmBotoes').hide();
			cTodosConsulta.desabilitaCampo();
			$('#frmInfMovimentacao').css({'display':'block'});			
			formataTabelaMovimentacao();
			$('#divMovimentacao').css({'display':'block'});
			
			//Ao clicar no botao btVoltar
			$('#btVoltar','#divBotoes').unbind('click').bind('click', function(){
				
				btnVoltar(2);
				
				return false;						
				
			}).focus();	
			
		</script>
		<?php
	}else{
		
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
			$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$erros 		= exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial()",false);
		} 	
		
		?>
		<script type="text/javascript">
			showError("inform","Fechamento realizado com sucesso!","Alerta - Ayllos","estadoInicial()");
		</script>
		<?php
	}

?>