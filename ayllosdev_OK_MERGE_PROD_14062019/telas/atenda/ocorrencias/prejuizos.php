<?php 

	/************************************************************************
	      Fonte: prejuizos.php
	      Autor: Guilherme
	      Data : Fevereiro/2008               &Uacute;ltima Altera&ccedil;&atilde;o: 13/07/2011

	      Objetivo  : Mostrar opcao Prejuizos da rotina de OCORRENCIAS
                      da tela ATENDA

	      Altera&ccedil;&otilde;es:
				13/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	
	
                    19/06/2018 - Atualizado os detalhes da aba Prejuízo para considerar o prejuízo da Conta Corrente
                                 Diego Simas - AMcom - PRJ450
        
					11/01/2019 - Implementado informações com os dados dos prejuizos - P298.2.2 - Anderson-Alan Supero
        
	
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetPrejuizos  = "";
	$xmlGetPrejuizos .= "<Root>";
	$xmlGetPrejuizos .= "	<Cabecalho>";
	$xmlGetPrejuizos .= "		<Bo>b1wgen0027.p</Bo>";
	$xmlGetPrejuizos .= "		<Proc>lista_prejuizos</Proc>";
	$xmlGetPrejuizos .= "	</Cabecalho>";
	$xmlGetPrejuizos .= "	<Dados>";
	$xmlGetPrejuizos .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetPrejuizos .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetPrejuizos .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetPrejuizos .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetPrejuizos .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetPrejuizos .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetPrejuizos .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlGetPrejuizos .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetPrejuizos .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetPrejuizos .= "		<idseqttl>1</idseqttl>";
	$xmlGetPrejuizos .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetPrejuizos .= "	</Dados>";
	$xmlGetPrejuizos .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPrejuizos);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPrejuizos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPrejuizos->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPrejuizos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Prejuízos de empréstimos (Podendo conter a linha 100 que é Prejuízo em CC)
	$prejuizos      = $xmlObjPrejuizos->roottag->tags[0]->tags;
	
	//Montar array com prejuízo em CC  
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_ATENDA_OCORRENCIAS", "CONSULTA_PREJUIZO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto = getObjectXML($xmlResult);	

	$param = $xmlObjeto->roottag->tags[0]->tags[0];

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"controlaOperacao('');",false); 
	}else{
		$inprejuz= getByTagName($param->tags,'inprejuz');	 
	}
	//
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<div id="divTabPrejuizos">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th title="Contrato"><? echo utf8ToHtml('Contrato'); ?></th>
					<th title="Data de Transfer&ecirc;ncia"><? echo utf8ToHtml('Dt Transf'); ?></th>
					<th title="Valor Transferido para Preju&iacute;zo"><? echo utf8ToHtml('Vl Transf Preju');  ?></th>					
					<th title="Saldo Atual"><? echo utf8ToHtml('Sld Atu');  ?></th>					
          			<th title="Dias em Atraso"><? echo utf8ToHtml('Dias Atr'); ?></th>
          			<th title="Dias em Preju&iacute;zo"><? echo utf8ToHtml('Dias Preju'); ?></th>
          			<th title="Dias Total em Atraso"><? echo utf8ToHtml('Dias Tot Atr'); ?></th>
					<th title="Juros Remunerat&oacute;rio"><? echo utf8ToHtml('Jur Rem'); ?></th>  
					<th title="Multa"><? echo utf8ToHtml('Multa'); ?></th>
					<th title="Juros de mora"><? echo utf8ToHtml('Jur Mora'); ?></th>
					<th title="Imposto sobre Opera&ccedil;&otilde;es Financeiras"><? echo utf8ToHtml('IOF'); ?></th>  
          			<th title="Valor Pago Preju&iacute;zo"><? echo utf8ToHtml('Pg Preju'); ?></th>
          			<th title="Valor Abono Preju&iacute;zo"><? echo utf8ToHtml('Abo Preju'); ?></th>
          			<th title="Saldo Devedor"><? echo utf8ToHtml('Saldo Devedor'); ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
                for ($i = 0; $i < count($prejuizos); $i++) {
				?>
					<tr>
						<td><!-- Contrato -->
							<span><?php echo $prejuizos[$i]->tags[1]->cdata; ?></span>
								<?php echo formataNumericos("z.zzz.zzz",$prejuizos[$i]->tags[1]->cdata,"."); ?>
						</td>
						<td><!-- Transferência -->
							<span><?php echo $prejuizos[$i]->tags[2]->cdata; ?></span>
								<?php echo $prejuizos[$i]->tags[2]->cdata; ?>
						</td>
						<td><!-- Valor Transferido para Prejuízo -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[3]->cdata); ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[3]->cdata),2,",","."); ?>
						</td>
						<td><!-- Saldo Atual -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[4]->cdata); ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[4]->cdata),2,",","."); ?>
						</td>
						<td><!-- Dias em Atraso -->
							<span><?php echo $prejuizos[$i]->tags[5]->cdata; ?></span>
								<?php echo $prejuizos[$i]->tags[5]->cdata; ?>
						</td>
						<td><!-- Dias em Preju?zo -->
							<span><?php echo $prejuizos[$i]->tags[6]->cdata; ?></span>
								<?php echo $prejuizos[$i]->tags[6]->cdata; ?>
						</td>
						<td><!-- Dias Total em Atraso -->
							<span><?php echo $prejuizos[$i]->tags[7]->cdata; ?></span>
								<?php echo $prejuizos[$i]->tags[7]->cdata; ?>
						</td>
						<td><!-- Juros Remunerat?rio -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[8]->cdata); ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[8]->cdata),2,",","."); ?>
						</td>
						<td><!-- Multa -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[9]->cdata); ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[9]->cdata),2,",","."); ?>
						</td>
						<td><!-- Juros de mora -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[10]->cdata); ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[10]->cdata),2,",","."); ?>
						</td>
						<td><!-- IOF -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[11]->cdata); ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[11]->cdata),2,",","."); ?>
						</td>
						<td><!-- Valor Pago Preju?zo  -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[12]->cdata); ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[12]->cdata),2,",","."); ?>
						</td>
						<td><!-- Valor Abono Preju?zo  -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[13]->cdata); ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[13]->cdata),2,",","."); ?>
						</td>
						<td><!-- Saldo Devedor  -->
							<span><?php echo str_replace(",",".",$prejuizos[$i]->tags[14]->cdata) ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[14]->cdata),2,",","."); ?>
						</td>
					</tr>
				<?  
				} 
				?>	
				<?
				if($inprejuz == "S"){
				?>
					<tr>
						<td><!-- Contrato -->
							<span><?php echo $nrdconta; ?></span>
						    <?php echo formataNumericos("z.zzz.zzz",$nrdconta,"."); ?>
						</td>
						<td><!-- Transferência -->
							<span><? echo getByTagName($param->tags,'dttransf'); ?></span>
							<? echo getByTagName($param->tags,'dttransf'); ?>							
						</td>
						<td><!-- Valor Transferido para Prejuízo -->
							<span><?php echo str_replace(",",".",getByTagName($param->tags,'vltrapre')) ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($param->tags,'vltrapre')),2,",","."); ?>
						</td>	
						<td><!-- Saldo Atual -->
							<span><?php echo str_replace(",",".",getByTagName($param->tags,'vlsdprej')) ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($param->tags,'vlsdprej')),2,",","."); ?>
						</td>					
						<td><!-- Dias em Atraso -->
							<span><? echo getByTagName($param->tags,'qtdiaatr'); ?></span>
							<? echo getByTagName($param->tags,'qtdiaatr'); ?>
						</td>
						<td><!-- Dias em Prejuízo -->
							<span><? echo getByTagName($param->tags,'qtdiapre'); ?></span>
							<? echo getByTagName($param->tags,'qtdiapre'); ?>
						</td>
						<td><!-- Dias Total em Atraso -->
							<span><? echo getByTagName($param->tags,'qtdittat'); ?></span>
							<? echo getByTagName($param->tags,'qtdittat'); ?>
						</td>
						<td><!-- Juros Remuneratório  -->
							<span><?php echo str_replace(",",".",getByTagName($param->tags,'vljuprej')) ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($param->tags,'vljuprej')),2,",","."); ?>
						</td>
                        <td><span>----</span>----</td><!-- Multa -->
                        <td><span>----</span>----</td><!-- Juros de Mora -->
						<td><!-- IOF  -->
							<span><?php echo str_replace(",",".",getByTagName($param->tags,'valoriof')) ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($param->tags,'valoriof')),2,",","."); ?>
						</td>
						<td><!-- Valor Pago Prejuízo  -->
							<span><?php echo str_replace(",",".",getByTagName($param->tags,'vlpagpre')) ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($param->tags,'vlpagpre')),2,",","."); ?>
						</td>
						<td><!-- Valor Abono Prejuízo  -->
							<span><?php echo str_replace(",",".",getByTagName($param->tags,'vlabopre')) ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($param->tags,'vlabopre')),2,",","."); ?>
						</td>
						<td><!-- Saldo Devedor  -->
							<span><?php echo str_replace(",",".",getByTagName($param->tags,'vlslddev')) ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($param->tags,'vlslddev')),2,",","."); ?>
						</td>
					</tr>
				<?
				}
				?>	
			</tbody>
		</table>
	</div>	
</div>


<script type="text/javascript">
// Formata layout
formataPrejuizos();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
