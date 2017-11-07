<?php
/*!
 * FONTE        : buscar_contas_demitidas.php                    �ltima altera��o:
 * CRIA��O      : Jonata (RKAM)
 * DATA CRIA��O : Junho/2017
 * OBJETIVO     : Rotina respons�vel por buscar as contas demitidas  - Op��o "G" da tela Matric
 * --------------
 * ALTERA��ES   :  
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

    // Carrega permiss�es do operador
    require_once('../../includes/carrega_permissoes.php');

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"G")) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
	
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	  
	$xmlMatric  = '';
	$xmlMatric .= '<Root>';
	$xmlMatric .= '	<Cabecalho>';
	$xmlMatric .= '		<Bo>b1wgen0052.p</Bo>';
	$xmlMatric .= '		<Proc>busca_contas_demitidas</Proc>';
	$xmlMatric .= '	</Cabecalho>';
	$xmlMatric .= '	<Dados>';
	$xmlMatric .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlMatric .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlMatric .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlMatric .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlMatric .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlMatric .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlMatric .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xmlMatric .= "     <nrregist>".$nrregist."</nrregist>";	
	$xmlMatric .= "     <nriniseq>".$nriniseq."</nriniseq>";
	$xmlMatric .= '	</Dados>';
	$xmlMatric .= '</Root>';
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xmlMatric);
	$xmlObjeto 	= getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','controlaVoltar();',false);		
							
	}
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$qtregist  = $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	
	$qtdContas = count($registros);	
		
	include('tab_contas_demitidas.php');	

 ?>
