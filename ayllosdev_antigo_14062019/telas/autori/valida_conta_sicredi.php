<? 
/*!
 * FONTE        : valida_conta_sicredi.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : 20/06/2014
 * OBJETIVO     : Rotina para validar o conta sicredi da tela AUTORI
 * --------------
 * ALTERAÇÕES   : 17/12/2014 - Desabilitar campo flgmanua quando der a critica (Lucas R. #234429)
 *
 *				  02/02/2015 - Retirado Validação de acesso (Lucas R. #247157)
 *
 *                09/03/2015 - Habilitar campo flgmanua aqui no php da validacao
 *                             ao inves de no javascript, pois ocorria problemas
 *                             com fluxo da tela (SD260803 - Tiago).
 *
 *                10/04/2015 - #265405 Inclusao do parametro cdoperad na procedure
 *                             valida_conta_sicredi para validar o horario para
 *                             inclusao de deb auto sicredi pelo seu PA de trabalho (Carlos)
 *
 *				  13/04/2015 - Bloquear campo flgsicre apos validacao (Lucas Ranghetti #275084)
 *
 *                16/10/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 */
?> 

<?php
	session_start();

	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
   
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	$cddopcao = $operacao[0];
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0092.p</Bo>";
	$xml .= "		<Proc>valida_conta_sicredi</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";	
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
							
		if ($msgErro == 'Conta Sicredi nao cadastrada.') {
			$metodo = "showConfirmacao('Deseja gerar conta Sicredi?','Confirma&ccedil;&atilde;o - Aimaro','gerarContaSicredi();','','sim.gif','nao.gif');";
		}		
		else {		
			$metodo = '$(\'#flgsicre\',\'#frmAutori\').focus();$(\'#flgmanua\',\'#frmAutori\').desabilitaCampo();';	
		}		
				
		exibirErro('error',$msgErro,'Alerta - Aimaro',$metodo,false);
		
	}
	
	echo 'desabilitaFaturas(\'#flgsicre\');';
	echo '$(\'#flgmanua\',\'#frmAutori\').habilitaCampo();';
	echo '$(\'#flgmanua\',\'#frmAutori\').focus();';
	

	echo "hideMsgAguardo();";
?>
