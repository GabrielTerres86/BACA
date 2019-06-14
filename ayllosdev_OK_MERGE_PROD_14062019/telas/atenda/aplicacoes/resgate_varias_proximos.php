<?php 

	/********************************************************************************************
	 Fonte: resgate_varias_proximos.php                                      
	 Autor: Jorge                                                            
	 Data : Agosto/2011                 Ultima Alteracao: 30/04/2014         
	                                                                         
	 Objetivo  : Mostrar opcao PROXIMOS da rotina de Aplicacoes              
			     da tela ATENDA em RESGATAR VARIAS                          
	                                                                          
	 Alteracoes: 30/04/2014 - Ajuste referente ao projeto Captação: - Layout dos botões	(Adriano). 					 
						
				 02/03/2015 - Chamada de procedure via OCI(Jean Michel).
				 
	***********************************************************************************************/
	
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
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>1</idseqttl>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<flgcance>0</flgcance>";
	$xml .= "		<flgerlog>0</flgerlog>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ATENDA", "CONRESGPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
				
	// Se ocorrer um erro, mostra crítica
	if(strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}		
		exibeErro($msgErro);			
		exit();
	} 
	
	$resgates   = $xmlObj->roottag->tags;	
	$qtResgates = count($resgates);
		
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))"; var lstResgates = new Array(); </script>
<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th style="display:none;"><?php echo utf8ToHtml('Dt.Aplic.'); ?></th> <!-- campo hidden, utilizado para ordenacao -->
				<th onclick="selLinhaProVarias();" title="Aplica&ccedil;&atilde;o"><?php echo utf8ToHtml('Aplica&ccedil;&atilde;o'); ?></th>
				<th onclick="selLinhaProVarias();" title="Data de Resgate"><?php echo utf8ToHtml('Dt.Resg.'); ?></th>
				<th onclick="selLinhaProVarias();" title="Documento"><?php echo utf8ToHtml('Docmto');  ?></th>
				<th onclick="selLinhaProVarias();" title="Tipo de Resgate"><?php echo utf8ToHtml('Tp.Resg.');  ?></th>
				<th onclick="selLinhaProVarias();" title="Situa&ccedil;&atilde;o"><?php echo utf8ToHtml('Situa&ccedil;&atilde;o');  ?></th>
				<th onclick="selLinhaProVarias();" title="Valor"><?php echo utf8ToHtml('Valor');  ?></th>
			</tr>
		</thead>
		<tbody>
			<?php 
			for ($i = 0; $i < $qtResgates; $i++) { 
				$dtresgat = getByTagName($resgates[$i]->tags,"DTRESGAT");
				$nrdocmto = getByTagName($resgates[$i]->tags,"NRDOCMTO");
				$tpresgat = getByTagName($resgates[$i]->tags,"TPRESGAT");
				$dsresgat = getByTagName($resgates[$i]->tags,"DSRESGAT");
				$nmoperad = getByTagName($resgates[$i]->tags,"NMOPERAD");
				$hrtransa = getByTagName($resgates[$i]->tags,"HRTRANSA");
				$vllanmto = getByTagName($resgates[$i]->tags,"VLLANMTO");
				$nraplica = getByTagName($resgates[$i]->tags,"NRAPLICA");
				$dshistor = getByTagName($resgates[$i]->tags,"DSHISTOR");
				$dtmvtolt = getByTagName($resgates[$i]->tags,"DTMVTOLT");
				$dtaplica = getByTagName($resgates[$i]->tags,"DTAPLICA");
				$idtipapl = getByTagName($resgates[$i]->tags,"IDTIPAPL");	
				
				if($nraplica == 0 || $nraplica == ''){
					continue;
				}
			?>
			<script type="text/javascript">
				objResgate = new Object();						
				objResgate.dtresgat = "<?php echo $dtresgat; ?>";
				objResgate.nrdocmto = "<?php echo $nrdocmto; ?>";
				objResgate.tpresgat = "<?php echo $tpresgat; ?>";
				objResgate.dsresgat = "<?php echo $dsresgat; ?>";
				objResgate.nmoperad = "<?php echo $nmoperad; ?>";
				objResgate.hrtransa = "<?php echo $hrtransa; ?>";
				objResgate.vllanmto = "<?php echo $vllanmto; ?>";
				objResgate.nraplica = "<?php echo $nraplica; ?>";
				objResgate.dshistor = "<?php echo $dshistor; ?>";
				objResgate.dtmvtolt = "<?php echo $dtmvtolt; ?>";
				objResgate.dtaplica = "<?php echo $dtaplica; ?>";
				objResgate.idtipapl = "<?php echo $idtipapl; ?>";
				lstResgates[<?php echo $i; ?>] = objResgate;
			</script>
			
			<tr id="trResgateVarias<?php echo $i + 1; ?>" onclick="viewComplementoResgVarias('<?php echo $i; ?>','P');">
				<td style="display:none;"><span><?php echo dataParaTimestamp($dtaplica); ?></span>
					<?php echo $dtaplica; ?>
				</td>
				<td><span><?php echo $nraplica; ?></span>
					<?php echo formataNumericos("zzz.zzz.zzz",$nraplica,"."); ?>
				</td>
				<td><span><?php echo dataParaTimestamp($dtresgat); ?></span>
					<?php echo $dtresgat; ?>
				</td>
				<td><span><?php echo $nrdocmto; ?></span>
					<?php echo $nrdocmto; ?>
				</td>
				<td><span><?php echo $tpresgat; ?></span>
					<?php echo $tpresgat; ?>
				</td>
				<td><span><?php echo $dsresgat; ?></span>
					<?php echo $dsresgat; ?>
				</td>
				<td><span><?php echo str_replace(",",".",$vllanmto); ?></span>
					<?php echo number_format(str_replace(",",".",$vllanmto),2,",","."); ?>
				</td>
			</tr>
		<? } ?>	
		
		</tbody>
	</table>
</div>	

<ul class="complemento">
<li style="font-weight:bold;font-size:11px">Dt.Solic:</li>
<li style="width:60px;font-size:11px" id="tdSoli"></li>
<li style="font-weight:bold;font-size:11px">Hist:</li>
<li style="width:125px;font-size:11px" id="tdHist"></li>
<li style="font-weight:bold;font-size:11px">Ope.Resg:</li>
<li style="width:95px;font-size:11px" id="tdOper"></li>
<li style="font-weight:bold;font-size:11px">Hor.Resg:</li>
<li style="width:20px;font-size:11px" id="tdHres"></li>
</ul>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="voltarDivResgatarVarias();return false;">Voltar</a>
</div>

<script type="text/javascript">	

// Formata tabela
formataTabelaResgateNoCheck();

$("#divResgatarVarias").css("display","none");	
$("#divOpcoes").css("display","block");

<?php if ($qtResgates > 0) { ?>
$("#trResgateVarias1").click();
<?php } ?>

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));	

</script>