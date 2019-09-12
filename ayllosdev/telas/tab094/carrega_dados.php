<?php
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Tiago                                                  
	  Data : Julho/2012                       Última Alteração: 27/06/2013		   
	                                                                   
	  Objetivo  : Carregar os dados da tela TAB094.              
	                                                                 
	  Alterações: 27/06/2013 - Adicionados dois novos campos: mrgitgcr e mrgitgdb (Reinert).										   			  
	                                                                  
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
	
	/*
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	} */
	
	
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0139.p</Bo>";
	$xmlCarregaDados .= "    <Proc>busca_dados</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
	} 
	
	$dados = $xmlObjCarregaDados->roottag->tags[0]->tags;
	
	$mrgsrdoc = $dados[0]->tags[0]->cdata;
	$mrgsrchq = $dados[0]->tags[1]->cdata;
	$mrgnrtit = $dados[0]->tags[2]->cdata;
	$mrgsrtit = $dados[0]->tags[3]->cdata;
	$caldevch = $dados[0]->tags[4]->cdata;
	$mrgitgcr = $dados[0]->tags[5]->cdata;
	$mrgitgdb = $dados[0]->tags[6]->cdata;
	$horabloq = $dados[0]->tags[7]->cdata;
	
	$arrHorabloq = explode(":",$horabloq);
	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
	
		 
?>

<script type="text/javascript">	
	$('#mrgsrdoc','#frmTab094').val('<? echo $mrgsrdoc ?>');
	$('#mrgsrchq','#frmTab094').val('<? echo $mrgsrchq ?>');
	$('#mrgnrtit','#frmTab094').val('<? echo $mrgnrtit ?>');
	$('#mrgsrtit','#frmTab094').val('<? echo $mrgsrtit ?>');
	$('#caldevch','#frmTab094').val('<? echo $caldevch ?>');
	$('#mrgitgcr','#frmTab094').val('<? echo $mrgitgcr ?>');	
	$('#mrgitgdb','#frmTab094').val('<? echo $mrgitgdb ?>');
	$('#horabloq','#frmTab094').val('<? echo $arrHorabloq[0]; ?>');	
	$('#horabloq2','#frmTab094').val('<? echo $arrHorabloq[1]; ?>');
</script>

