<?
/*
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Ramirez
 * DATA CRIAÇÃO : 11/04/2011 
 * OBJETIVO     : Mostrar opcao Principal da rotina de DDA da tela de CONTAS 
 * 
 * ALTERACOES   :
 */ 
 ?>
 
 <?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);
		
			
	// Guardo os parâmetos do POST em variáveis		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0  ;
	
	
	// Monta o xml de requisição
	$xmlGetTitulares  = "";
	$xmlGetTitulares .= "<Root>";
	$xmlGetTitulares .= "	<Cabecalho>";
	$xmlGetTitulares .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetTitulares .= "		<Proc>obtem-dados-titulares</Proc>";
	$xmlGetTitulares .= "	</Cabecalho>";
	$xmlGetTitulares .= "	<Dados>";
	$xmlGetTitulares .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetTitulares .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetTitulares .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetTitulares .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetTitulares .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetTitulares .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetTitulares .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetTitulares .= "		<idseqttl>1</idseqttl>";
	$xmlGetTitulares .= "	</Dados>";
	$xmlGetTitulares .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetTitulares);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjTitulares = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjTitulares->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTitulares->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$inpessoa    = $xmlObjTitulares->roottag->tags[0]->attributes["INPESSOA"];
	$titulares   = $xmlObjTitulares->roottag->tags[1]->tags;
	$qtTitulares = count($titulares);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";</script>

<div id="divTitularDDAPrincipal">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Sequ&ecirc;ncia</th>
					<th>Titular</th>
				</tr>			
			</thead>
			<tbody>
				<?  for ($i = 0; $i < $qtTitulares; $i++) { 
										
						$mtdClick = "selecionaTitular('".$titulares[$i]->tags[0]->cdata."','".$qtTitulares."');";
					?>
					<tr id="trTitInternet<?php echo $titulares[$i]->tags[0]->cdata; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>acessaTitular();">
						
						<td><?php echo $titulares[$i]->tags[0]->cdata; ?></td>
						
						<td><?php echo $titulares[$i]->tags[1]->cdata; ?></td>
					</tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>	
<?
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibeErro('Conta/dv inv&aagcute;lida.');
	if (!validaInteiro($idseqttl)) exibeErro('Seq.Ttl n&atilde;o foi informada.');
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0078.p</Bo>';
	$xml .= '		<Proc>consulta-sacado-eletronico</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagecxa>0</cdagecxa>';
	$xml .= '		<nrdcaixa>0</nrdcaixa>';
	$xml .= '		<cdopecxa>'.$glbvars['cdoperad'].'</cdopecxa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
						
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
       exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}	 
	
	$dda = $xmlObjeto->roottag->tags[0]->tags;
			
	include('formulario_dda.php');	
	
	/* // Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		 ?><script language="javascript">hideMsgAguardo();$("#divRotina").css({'display':'none'});alert('<?php echo $msgErro; ?>')</script><?php
	     exit();
	}  */
	
 ?>
<script >
	controlaLayoutTabela();
</script>
