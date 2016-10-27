<?
/*!
 * FONTE        : valida_dados_cartao.php
 * CRIA��O      : Jean Michel
 * DATA CRIA��O : Abril/2014
 * OBJETIVO     : Verifica se primeiro titular possui cart�o e busca dados referentes ao cart�o.
 * --------------
 * ALTERA��ES   : 001: [26/07/2014] Daniel :Comentado verificacao de permissao (Daniel).
 *                
 *     			  002: [20/08/2014] Daniel : Incluso ajustes solicitacao cartao pessoa juridica. SoftDesk 188116.	
 *
 * 				  003: [24/09/2014] Renato : Adicionar tratamento para atualiza��o do campo nmempres 
 *				  
 *		     	  004: [24/12/2014] Vanessa : Obrigar o Preecnhimeto do campo forma de Pagamento SD 236434 
 *
 * 				  013: [03/07/2015] Renato Darosci : Impedir que seja poss�vel informar limite para cart�o somente d�bito
 *
 *                006: [16/07/2015] Carlos : #308949 Desativado o campo Forma de pagamento quando o cooperado pj j� possui cart�o.
 *
 *                007: [09/10/2015] James: Desenvolvimento do projeto 126.
 *
 *                008: [28/04/2016] Douglas: Adicionar o campo flgdebit para verificar se o primeiro cartao solicitado possui a opcao de debito habilitada. 
 *                                           Quando o primeiro cartao for solicitado sem a opcao de debito todos os cartoes adicionais devem ser identicos 
 *                                           (Chamado 415437)
				  
				  009: [21/10/2016] Kelvin : #530857 Ajustado o campo "Envio" que no IE nao carregava a informacao correta.
											 
 * --------------
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica permiss�o
/*	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro,false);
	}	
*/	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["cdadmcrd"]) || !isset($_POST["nrcpfcgc"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}	

	$nrdconta = $_POST["nrdconta"];
	$cdadmcrd = $_POST["cdadmcrd"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$nmtitcrd = $_POST["nmtitcrd"];
	
	$inpessoa = $_POST["inpessoa"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	if (!validaInteiro($cdadmcrd)) exibirErro('error','Administradora de Cart&atilde;o inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	
    // Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_dados_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<cdadmcrd>".$cdadmcrd."</cdadmcrd>";
	$xmlSetCartao .= "		<nmtitcrd>".$nmtitcrd."</nmtitcrd>";
	$xmlSetCartao .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";	
	$xmlSetCartao .= "		<inpessoa>".$inpessoa."</inpessoa>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjCartao->roottag->tags[0]->cdata;
		$msgErro = $msgErro == null || $msgErro == '' ? $xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata : $msgErro;
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","voltaDiv(0,1,5); bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);");';
	}else{
		//Caso consulta retorne dados
		$dddebito = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
		$dddebito = str_pad($dddebito, 2, "0", STR_PAD_LEFT);  // Preencher com zeros a esquerda ( Renato - Supero - 23/09/2014)
		$vllimcrd = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
		$tpenvcrd = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[2]->cdata;
		$tpdpagto = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[3]->cdata;
		
		$nmempres = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		// Identifica se o cartao possui a opcao debito habilitada
		$flgdebit = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[5]->cdata;
		
		echo 'bloqueiaFundo(divRotina);';
		
		if ($inpessoa == 1 ) {

			//chw+
		    if ( $vllimcrd <> 0 ) {
				echo "$('#vllimpro').desabilitaCampo();";
			}	
		
			if ($tpdpagto == 0){
				echo '$("#tpdpagto","#frmNovoCartao").val(0);';
			}else if ($tpdpagto == 1){
				echo '$("#tpdpagto","#frmNovoCartao").val(1);';
			}else if ($tpdpagto == 2){
				echo '$("#tpdpagto","#frmNovoCartao").val(2);';
			}else{
				echo '$("#tpdpagto","#frmNovoCartao").val(3);';
			}
			
			/*Como foi removido a opcao cooperado no campo Envio
			  neste momento, forcamos o valor 1 ("Cooperativa") no campo*/
			echo '$("#tpenvcrd","#frmNovoCartao").val(1);';
			
			echo '$("#dddebito","#frmNovoCartao").val("'.$dddebito.'");';
			echo "$('#dddebito').attr('disabled', true);";
			echo "$('#tpenvcrd').attr('disabled', true);";
			echo "atualizaCampoLimiteProposto(new Array('".formataMoeda($vllimcrd)."'));";

			// Habilitar o campo "Habilita Funcao de Debito"
			echo "$('#flgdebit','#frmNovoCartao').habilitaCampo();";
			// Verificar se retornou a funcao debito
			if ($flgdebit != "") {
				// Verfica se a esta habilitada no primeiro cartao
				if (strtoupper($flgdebit) == "YES"){
					// Marcar o campo no novo cartao
					echo "$('#flgdebit','#frmNovoCartao').attr('checked', true);";
				} else {
					// Desabilitar o campo para nao permitir alterar
					echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
					// Somente quando o primeiro cartao for SOMENTE CREDITO que a op��o deve ficar desabilitada
					echo "$('#flgdebit','#frmNovoCartao').attr('checked', false);";
				}
			}
			
		} else {

			if ($nmempres <> "") {
				echo '$("#nmempres","#frmNovoCartao").val("'.$nmempres.'");'; // Renato - Supero
			}

			if ( $vllimcrd <> 0 ) {	
					
				if ($tpdpagto == 0){
					echo '$("#tpdpagto","#frmNovoCartao").val("0");';
				}else if ($tpdpagto == 1){
					echo '$("#tpdpagto","#frmNovoCartao").val("1");';
				}else if ($tpdpagto == 2){
					echo '$("#tpdpagto","#frmNovoCartao").val("2");';
				}else{
					echo '$("#tpdpagto","#frmNovoCartao").val("3");';
				}
				
				/*Como foi removido a opcao cooperado no campo Envio
				  neste momento, forcamos o valor 1 ("Cooperativa") no campo*/
				echo '$("#tpenvcrd","#frmNovoCartao").val(1);';
				
				echo '$("#dddebito","#frmNovoCartao").val("'.$dddebito.'");';
				echo '$("#nmempres","#frmNovoCartao").val("'.$nmempres.'");'; // Daniel

				echo "$('#dddebito').attr('disabled', true);";
				echo "$('#vllimpro').desabilitaCampo();";
				echo "$('#tpenvcrd').attr('disabled', true);";
				echo "$('#tpdpagto').attr('disabled', true);";
				
				echo "$('#nmempres').attr('disabled', true);"; // Daniel		
				echo "atualizaCampoLimiteProposto(new Array('".formataMoeda($vllimcrd)."'));";
		
			}  else {
			
				echo "$('#dddebito').attr('disabled', false);";				
				echo "$('#tpenvcrd').attr('disabled', false);";
				echo "$('#tpdpagto').attr('disabled', false);";
				echo '$("#tpdpagto","#frmNovoCartao").val("0");';
			} 

			// Habilitar o campo "Habilita Funcao de Debito"
			echo "$('#flgdebit','#frmNovoCartao').habilitaCampo();";
			// Verificar se retornou a funcao debito
			if ($flgdebit != "") {
				// Verfica se a esta habilitada no primeiro cartao
				if (strtoupper($flgdebit) == "YES"){
					// Marcar o campo no novo cartao
					echo "$('#flgdebit','#frmNovoCartao').attr('checked', true);";
				} else {
					// Desabilitar o campo para nao permitir alterar
					echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
					// Somente quando o primeiro cartao for SOMENTE CREDITO que a op��o deve ficar desabilitada
					echo "$('#flgdebit','#frmNovoCartao').attr('checked', false);";
				}
			}
		}
	}
?>