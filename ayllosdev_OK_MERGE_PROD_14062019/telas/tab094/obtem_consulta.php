<?php
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Tiago                                                  
	  Data : Julho/2012                         Última Alteração: 04/07/2013		   
	                                                                   
	  Objetivo  : Carrega os dados da tela TAB094.              
	                                                                 
	  Alterações: 02/10/2012 - Ajuste referente ao projeto Fluxo Financeiro (Adriano).
				  27/06/2013 - Adicionados dois novos campos: mrgitgcr e mrgitgdb (Reinert).
				  04/07/2013 - Alterado para receber o novo layout padrão do Ayllos Web (Reinert).
				  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	$cdcoopex = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ;	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0  ;	
		
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

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
	$xmlCarregaDados .= "	 <cdcoopex>".$cdcoopex."</cdcoopex>";	
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		$msgErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		
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
			
	include('form_tab094.php');
?>

<script type="text/javascript">	

	formataFormulario();
	layoutPadrao();
	
	if ('<? echo $cddopcao ?>' == "C") {
		
			$('#mrgsrdoc','#frmTab094').desabilitaCampo();
			$('#mrgsrchq','#frmTab094').desabilitaCampo();
			$('#mrgnrtit','#frmTab094').desabilitaCampo();
			$('#mrgsrtit','#frmTab094').desabilitaCampo();
			$('#caldevch','#frmTab094').desabilitaCampo();
			$('#mrgitgcr','#frmTab094').desabilitaCampo();
			$('#mrgitgdb','#frmTab094').desabilitaCampo();
			$('#horabloq','#frmTab094').desabilitaCampo();
			$('#horabloq2','#frmTab094').desabilitaCampo();
			$('#divMsgAjuda').css('display','block');
			$('#btVoltar','#divMsgAjuda').show();			
			$("#btAlterar","#divMsgAjuda").hide();
			$('#cddopcao','#frmCabTab094').focus();
						
	} else {	

			$('#mrgsrdoc','#frmTab094').habilitaCampo();
			$('#mrgsrchq','#frmTab094').habilitaCampo();
			$('#mrgnrtit','#frmTab094').habilitaCampo();
			$('#mrgsrtit','#frmTab094').habilitaCampo();
			$('#caldevch','#frmTab094').habilitaCampo();
			$('#mrgitgcr','#frmTab094').habilitaCampo();
			$('#mrgitgdb','#frmTab094').habilitaCampo();
			$('#horabloq','#frmTab094').habilitaCampo();
			$('#horabloq2','#frmTab094').habilitaCampo();
			$('#divMsgAjuda').css('display','block');
			$('#btVoltar','#divMsgAjuda').show();
			$("#btAlterar","#divMsgAjuda").show();
			$('#mrgsrdoc','#frmTab094').focus();

		}
		

	$('#mrgsrdoc','#frmTab094').val('<? echo formataMoeda($mrgsrdoc); ?>');
	$('#mrgsrchq','#frmTab094').val('<? echo formataMoeda($mrgsrchq); ?>');
	$('#mrgnrtit','#frmTab094').val('<? echo formataMoeda($mrgnrtit); ?>');
	$('#mrgsrtit','#frmTab094').val('<? echo formataMoeda($mrgsrtit); ?>');
	$('#caldevch','#frmTab094').val('<? echo formataMoeda($caldevch); ?>');			
	$('#mrgitgcr','#frmTab094').val('<? echo formataMoeda($mrgitgcr); ?>');
	$('#mrgitgdb','#frmTab094').val('<? echo formataMoeda($mrgitgdb); ?>');
	$('#horabloq','#frmTab094').val('<? echo $arrHorabloq[0]; ?>');	
	$('#horabloq2','#frmTab094').val('<? echo $arrHorabloq[1]; ?>');
	
</script>

