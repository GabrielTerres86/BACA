<?php 

	/***************************************************************************
	 Fonte: Cheques_historico.php
	 Autor: Paulo Roberto Martins Junior
	 Data : Julho/2019
	 
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC CHQS");
	
	require_once("../../../../includes/carrega_permissoes.php");

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
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}   
?>
<div id="divTitulosUltAlteracoes">
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
					<th>Data de Cancelamento</th>
				</tr>			
			</thead>
			<tbody>
				<?  for ($i = 0; $i < $qtLimites; $i++) {
                  //Somente mostra os Cancelados
	              if ($limites[$i]->tags[10]->cdata != 3) {
	               continue;
	              }
												
						$mtdClick = "selecionaLimiteCheques('".($i + 1)."','".$qtLimites."','".($limites[$i]->tags[3]->cdata)."','".($limites[$i]->tags[6]->cdata)."','".($limites[$i]->tags[10]->cdata)."','".($limites[$i]->tags[2]->cdata)."',".($limites[$i]->tags[11]->cdata).");";
				?>
					<tr id="trLimite<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
					
						<td>
              <?php

              echo $limites[$i]->tags[0]->cdata; ?>
            </td>
						
						<td><? echo $limites[$i]->tags[1]->cdata; ?></td>
						
						<td><span><? echo $limites[$i]->tags[3]->cdata; ?></span>
							<? echo formataNumericos('zzz.zzz.zzz',$limites[$i]->tags[3]->cdata,'.'); ?></td>
						
						<td><span><? echo $limites[$i]->tags[2]->cdata; ?></span>
							<? echo number_format(str_replace(",",".",$limites[$i]->tags[2]->cdata),2,",","."); ?></td>
						
						<td><? echo $limites[$i]->tags[4]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[5]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[6]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[9]->cdata; ?></td>
						<!--Data de cancelamento-->
						<td><? echo $limites[$i]->tags[14]->cdata; ?></td>
					</tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>

<!-- PRJ 438 - Sprint 16 - Incluido botão voltar, para voltar para a tela principal -->
<div id="divBotoes">
	<a href="#" class="botao" id="btVoltarDescCheques" onclick="carregaLimitesCheques();return false;">Voltar</a>
</div>

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao2","divConteudoOpcao1");

	formataLayout('divTitulosUltAlteracoes');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>