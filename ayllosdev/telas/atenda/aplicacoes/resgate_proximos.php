<?php 

	/************************************************************************
	 Fonte: resgate_proximos.php                                      
	 Autor: David                                                     
	 Data : Outubro/2009                 	     Última alteração: 30/12/2014 
	                                                                  
	 Objetivo  : Mostrar opcao PROXIMOS da rotina de Aplicações da    
	             tela ATENDA                                          
	                                                                  
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p 
				  			  para a BO b1wgen0081.p (Adriano)
											 
				 30/04/2014 - Ajuste referente ao projeto Captação:
							  - Layout dos botões							  
						      (Adriano). 
							  
				 30/12/2014 - Alterando (Reinert)
							  
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];
	$tpaplica = $_POST["tpaplica"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n&uacute;mero da aplica&ccedil;&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nraplica)) {
		exibeErro("N&uacute;mero da aplica&ccedil;&atilde;o inv&aacute;lida.");
	}		
	
	if($tpaplica == 'A'){
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlGetResgates  = "";
		$xmlGetResgates .= "<Root>";
		$xmlGetResgates .= "	<Cabecalho>";
		$xmlGetResgates .= "		<Bo>b1wgen0081.p</Bo>";
		$xmlGetResgates .= "		<Proc>obtem-resgates-aplicacao</Proc>";
		$xmlGetResgates .= "	</Cabecalho>";
		$xmlGetResgates .= "	<Dados>";
		$xmlGetResgates .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlGetResgates .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlGetResgates .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlGetResgates .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetResgates .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlGetResgates .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
		$xmlGetResgates .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlGetResgates .= "		<idseqttl>1</idseqttl>";
		$xmlGetResgates .= "		<nraplica>".$nraplica."</nraplica>";
		$xmlGetResgates .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlGetResgates .= "		<flgcance>no</flgcance>";
		$xmlGetResgates .= "	</Dados>";
		$xmlGetResgates .= "</Root>";
			
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetResgates);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjResgates = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjResgates->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjResgates->roottag->tags[0]->tags[0]->tags[4]->cdata);
		} 
		
		$resgates   = $xmlObjResgates->roottag->tags[0]->tags;		
		$qtResgates = count($resgates);
		
	}else{
		// Montar o xml de Requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";		
		$xml .= "	<idseqttl>1</idseqttl>";
		$xml .= "	<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";		
		$xml .= "	<nraplica>".$nraplica."</nraplica>";		
		$xml .= "   <flgcance>0</flgcance>";	
		$xml .= "   <flgerlog>0</flgerlog>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
			
		$xmlResult = mensageria($xml, "ATENDA", "CONRESGT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);					
			
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			
			exibeErro($msgErro);		
		} 
		
		$resgates   = $xmlObj->roottag->tags;		
		$qtResgates = count($resgates);		
	}		
	
	// Funcao para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.trim($msgErro).'","Alerta - Aimaro","encerraRotina(true); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
		
?>

<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Data'); ?></th>
				<th><? echo utf8ToHtml('Documento');  ?></th>
				<th><? echo utf8ToHtml('Tp.Resgate');  ?></th>
				<th><? echo utf8ToHtml('Situa&ccedil;&atilde;o');  ?></th>
				<th><? echo utf8ToHtml('Operador');  ?></th>
				<th><? echo utf8ToHtml('Hora');  ?></th>
				<th><? echo utf8ToHtml('Valor');  ?></th>
			</tr>
		</thead>
		<tbody>
			<? 
			for ($i = 0; $i < $qtResgates; $i++) { 
					
			?>
			<tr>
				<td><span><?php echo dataParaTimestamp($resgates[$i]->tags[0]->cdata); ?></span>
						  <?php echo $resgates[$i]->tags[0]->cdata; ?>				
				</td>
				<td><span><?php echo $resgates[$i]->tags[1]->cdata; ?></span>
						  <?php echo formataNumericos("zzz.zzz.zzz",$resgates[$i]->tags[1]->cdata,"."); ?>
				</td>
				<td><span><?php echo $resgates[$i]->tags[2]->cdata; ?></span>
						  <?php echo $resgates[$i]->tags[2]->cdata; ?>
				</td>
				<td><span><?php echo $resgates[$i]->tags[3]->cdata; ?></span>
						  <?php echo $resgates[$i]->tags[3]->cdata; ?>
				</td>
				<td><span><?php echo $resgates[$i]->tags[4]->cdata; ?></span>
						  <?php echo $resgates[$i]->tags[4]->cdata; ?>
				</td>
				<td><span><?php echo $resgates[$i]->tags[5]->cdata; ?></span>
						  <?php echo $resgates[$i]->tags[5]->cdata; ?>
				</td>
				<td><span><?php echo str_replace(",",".",$resgates[$i]->tags[6]->cdata); ?></span>
						  <?php echo number_format(str_replace(",",".",$resgates[$i]->tags[6]->cdata),2,",","."); ?>
				</td>

			</tr>
		<? } ?>	
		
		</tbody>
	</table>
</div>	

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="voltarDivResgate();return false;">Voltar</a>
</div>

<script type="text/javascript">	
	// Formata tabela
	formataTabelaResgate();

	$("#divResgate").css("display","none");	
	$("#divOpcoes").css("display","block");

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));	
</script>