<?php
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Tiago
	  Data : Julho/2012                       Última Alteração: 04/07/2013 		   
	                                                                   
	  Objetivo  : Grava parametros na craptab.             
	                                                                 
	  Alterações: 27/06/2013 - Adicionados dois novos campos: mrgitgcr e mrgitgdb (Reinert).
				  04/07/2013 - Alterado para receber o novo layout padrão do Ayllos Web (Reinert).
				  05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
                               departamento como parametros e passar o o código (Renato Darosci).
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
		
	$mrgsrdoc = (isset($_POST['mrgsrdoc'])) ? $_POST['mrgsrdoc'] : 0  ;	
	$mrgsrchq = (isset($_POST['mrgsrchq'])) ? $_POST['mrgsrchq'] : 0  ;	
	$mrgnrtit = (isset($_POST['mrgnrtit'])) ? $_POST['mrgnrtit'] : 0  ;	
	$mrgsrtit = (isset($_POST['mrgsrtit'])) ? $_POST['mrgsrtit'] : 0  ;	
	$caldevch = (isset($_POST['caldevch'])) ? $_POST['caldevch'] : 0  ;	
	$mrgitgcr = (isset($_POST['mrgitgcr'])) ? $_POST['mrgitgcr'] : 0  ;	
	$mrgitgdb = (isset($_POST['mrgitgdb'])) ? $_POST['mrgitgdb'] : 0  ;	
	$horabloq = (isset($_POST['horabloq'])) ? $_POST['horabloq'] : 0  ;	
	$horabloq2 = (isset($_POST['horabloq2'])) ? $_POST['horabloq2'] : 0  ;	
	$cdcoopex = (isset($_POST['cdcoopex'])) ? $_POST['cdcoopex'] : 0  ;	
	

	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "   <Bo>b1wgen0139.p</Bo>";
	$xmlCarregaDados .= "   <Proc>grava_dados</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCarregaDados .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlCarregaDados .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";		
	$xmlCarregaDados .= "	<mrgsrdoc>".$mrgsrdoc."</mrgsrdoc>";
	$xmlCarregaDados .= "   <mrgsrchq>".$mrgsrchq."</mrgsrchq>";
	$xmlCarregaDados .= "   <mrgnrtit>".$mrgnrtit."</mrgnrtit>";
	$xmlCarregaDados .= "   <mrgsrtit>".$mrgsrtit."</mrgsrtit>";
	$xmlCarregaDados .= "   <caldevch>".$caldevch."</caldevch>";
	$xmlCarregaDados .= "   <mrgitgcr>".$mrgitgcr."</mrgitgcr>";
	$xmlCarregaDados .= "   <mrgitgdb>".$mrgitgdb."</mrgitgdb>";
	$xmlCarregaDados .= "   <horabloq>".$horabloq.":".$horabloq2."</horabloq>";
	$xmlCarregaDados .= "   <cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xmlCarregaDados .= "   <cdcoopex>".$cdcoopex."</cdcoopex>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	echo 'hideMsgAguardo();';
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
	} 
	
    echo "showError('inform','Parametros alterados com sucesso!','Tab094','voltaDiv();estadoInicial();');";
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
?>