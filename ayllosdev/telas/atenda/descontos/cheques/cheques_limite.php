<?php

	/************************************************************************
	 Fonte: cheques_limite.php                                        
	 Autor: Guilherme                                                 
	 Data : Março/2009                Última Alteração: 12/09/2016
	                                                                  
	 Objetivo  : Mostrar opcao Limites de descontos de cheques da rotina         
	             Descontos da tela ATENDA                 		   	  
	                                                                  	 
	 Alterações:  25/06/2010 - Incluir campo de envio a sede (Gabriel). 

				  12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
				  
				  18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				  
				  11/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
							   de proposta de novo limite de desconto de cheque para
							    menores nao emancipados. (Reinert)

			      17/12/2015 - Edição de número do contrato de limite (Lunelli - SD 360072 [M175])

				  12/09/2016 - Inclusão do campo "Confirmar Novo Limite" que vai substituir a "LANCDC". PRJ300 (Lombardi)

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC CHQS - LIMITE");

	// Carrega permissões do operador
	include("../../../../includes/carrega_permissoes.php");	

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetLimites  = "";
	$xmlGetLimites .= "<Root>";
	$xmlGetLimites .= "	<Cabecalho>";
	$xmlGetLimites .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetLimites .= "		<Proc>busca_limites</Proc>";
	$xmlGetLimites .= "	</Cabecalho>";
	$xmlGetLimites .= "	<Dados>";
	$xmlGetLimites .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLimites .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetLimites .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetLimites .= "	</Dados>";
	$xmlGetLimites .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLimites);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimites = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimites->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimites->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$limites   = $xmlObjLimites->roottag->tags[0]->tags;
	$qtLimites = count($limites);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}    	
	
?>

<div id="divLimites">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Proposta</th>
					<th>Ini.Vig&ecirc;n.</th>
					<th>Contrato</th>
					<th>Limite</th>
					<th>Vig</th>
					<th>LD</th>
					<th >Situa&ccedil;&atilde;o</th>
					<th>Comit&ecirc;</th>
				</tr>			
			</thead>
			<tbody>
				<?  for ($i = 0; $i < $qtLimites; $i++) {
												
						$mtdClick = "selecionaLimiteCheques('".($i + 1)."','".$qtLimites."','".($limites[$i]->tags[3]->cdata)."','".($limites[$i]->tags[6]->cdata)."','".($limites[$i]->tags[10]->cdata)."','".($limites[$i]->tags[2]->cdata)."');";
				?>
					<tr id="trLimite<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
					
						<td><? echo $limites[$i]->tags[0]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[1]->cdata; ?></td>
						
						<td><span><? echo $limites[$i]->tags[3]->cdata; ?></span>
							<? echo formataNumericos('zzz.zzz.zzz',$limites[$i]->tags[3]->cdata,'.'); ?></td>
						
						<td><span><? echo $limites[$i]->tags[2]->cdata; ?></span>
							<? echo number_format(str_replace(",",".",$limites[$i]->tags[2]->cdata),2,",","."); ?></td>
						
						<td><? echo $limites[$i]->tags[4]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[5]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[6]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[9]->cdata; ?></td>
					</tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>
<div id = "divAlteraForm" style = "display:none"></div>

<?php
	$dispA = (!in_array("A",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispX = (!in_array("X",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispC = (!in_array("C",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispE = (!in_array("E",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispM = (!in_array("M",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispN = (!in_array("N",$glbvars["opcoesTela"])) ? 'display:none;' : '';
?>

	<a href="#" class="botao" name="btnConfNovLimite" id="btnConfNovLimite" style="<? echo $dispN ?>" onClick="confirmaNovoLimite();">Confirmar Novo Limite</a>
</div>

<script type="text/javascript">




// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
