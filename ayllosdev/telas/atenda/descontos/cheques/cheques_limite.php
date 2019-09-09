<?php

	/************************************************************************
	 Fonte: cheques_limite.php                                        
	 Autor: Guilherme                                                 
	 Data : Março/2009                Última Alteração: 11/12/2017
	                                                                  
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

				  26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).

                  11/12/2017 - P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero))

                  14/02/2019 - P450 - Inclusão dos campos nota do rating, origem da nota do rating e Status  (Luiz Otávio Olinger Momm - AMCOM)

                  05/03/2019 - P450 - Inclusão botao Alterar Rating (Luiz Otávio Olinger Momm - AMCOM)

                  07/03/2019 - P450 - Inclusão da consulta do parametro se a coopoerativa pode Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM).
                  
                  12/03/2019 - P450 - Inclusão botao Analisar (Luiz Otávio Olinger Momm - AMCOM)
                  
                  15/03/2019 - P450 - Inclusão da consulta Rating (Luiz Otávio Olinger Momm - AMCOM)

                  25/04/2019 - P450 - Ajustes de interface conforme solicitação Ailos (Luiz Otávio Olinger Momm - AMCOM).

                  13/05/2019 - P450 - Não mostrar Rating quando estiver como situação "não analisado" (Luiz Otávio Olinger Momm - AMCOM).

                  23/05/2019 - P450 - Removido mensageiria para pesquisa de rating por proposta (Luiz Otávio Olinger Momm - AMCOM).

                  02/07/2019 - PRJ 438 - Sprint 14 - Alterado nome do botão 'Confirmar Novo Limite' para 'Efetivar' (Mateus Z / Mouts)

                  17/07/2019 - PRJ 438 - Sprint 16 - Ultimas alterações do desconto de cheque  - Paulo Martins - Mouts
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
	$xmlGetLimites .= "		<Proc>busca_limite_ativo</Proc>";
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
	
	// [07/03/2019]
	$permiteAlterarRating = false;
	$oXML = new XmlMensageria();
	$oXML->add('cooperat', $glbvars["cdcooper"]);

	$xmlResult = mensageria($oXML, "TELA_PARRAT", "CONSULTA_PARAM_RATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	$registrosPARRAT = $xmlObj->roottag->tags[0]->tags;
	foreach ($registrosPARRAT as $r) {
		if (getByTagName($r->tags, 'pr_inpermite_alterar') == '1') {
			$permiteAlterarRating = true;
		}
	}
	// [07/03/2019]

	// ********************************************
	// AMCOM - Retira Etapa Rating exceto para Ailos (coop 3)

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdacesso>HABILITA_RATING_NOVO</cdacesso>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_CRAPPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjPRM = getObjectXML($xmlResult);

	$habrat = 'N';
	if (strtoupper($xmlObjPRM->roottag->tags[0]->name) == "ERRO") {
		$habrat = 'N';
	} else {
		$habrat = $xmlObjPRM->roottag->tags[0]->tags;
		$habrat = getByTagName($habrat[0]->tags, 'PR_DSVLRPRM');
	}

	if ($glbvars["cdcooper"] == 3) {
		$habrat = 'N';
	}
	// ********************************************
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
					<!-- [14/02/2019] -->
					<th><? echo utf8ToHtml('Nota Rating');?></th>
					<th title="Origem Rating"><? echo utf8ToHtml('Retorno');?></th>
					<!-- [14/02/2019] -->

				</tr>			
			</thead>
			<tbody>
				<?  for ($i = 0; $i < $qtLimites; $i++) {

						$msgErro = '';
						$notaRating = $limites[$i]->tags[12]->cdata;
						$origemRating = $limites[$i]->tags[13]->cdata;
						$situacaoRating = '';

						$mtdClick = "selecionaLimiteCheques('".($i + 1)."','".$qtLimites."','".($limites[$i]->tags[3]->cdata)."','".($limites[$i]->tags[6]->cdata)."','".($limites[$i]->tags[10]->cdata)."','".($limites[$i]->tags[2]->cdata)."',".($limites[$i]->tags[11]->cdata).");";
				?>
					<tr id="trLimite<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
					
						<td>
              <?php
              // Vamos salvar o numero do contrato ativo para usar na tela de garantia
              if ($limites[$i]->tags[10]->cdata == 2) {
                echo '<input type="hidden" name="nrcontratoativo" id="nrcontratoativo" value="'.$limites[$i]->tags[3]->cdata.'"/>';
              }
              echo $limites[$i]->tags[0]->cdata; ?>
            </td>
						
						<td><? echo $limites[$i]->tags[1]->cdata; ?></td>
						
						<td><span><? echo $limites[$i]->tags[3]->cdata; ?></span>
							<? echo formataNumericos('zzz.zzz.zzz',$limites[$i]->tags[3]->cdata,'.'); ?></td>
						
						<td><span><? echo $limites[$i]->tags[2]->cdata; ?></span>
							<? echo number_format(str_replace(",",".",$limites[$i]->tags[2]->cdata),2,",","."); ?></td>
						
						<td><? echo $limites[$i]->tags[4]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[5]->cdata; ?></td>
						
						<td title="<? echo stringTabela($limites[$i]->tags[6]->cdata, 50, 'primeira'); ?>"><? echo stringTabela($limites[$i]->tags[6]->cdata, 20, 'primeira'); ?></td>
						
						<td title="<? echo stringTabela($limites[$i]->tags[9]->cdata, 50, 'primeira'); ?>"><? echo stringTabela($limites[$i]->tags[9]->cdata, 20, 'primeira'); ?></td>

						<!-- [14/02/2019][15/03/2019] -->
						<td><?=$notaRating?></td>
						<td title="<?=stringTabela($origemRating, 30, 'primeira'); ?>"><?=stringTabela($origemRating, 10, 'primeira'); ?></td>
						<!-- [14/02/2019][15/03/2019] -->
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

	/* Criar Insert */
	$dispL = (!in_array("L",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispL = '';

	$dispT = (!in_array("T",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispT = '';
	/* Criar Insert */
?>

<div id="divBotoesChequesLimite">
	<a href="#" class="botao" name="btnVoltar" id="btnVoltar" onClick="voltaDiv(2,1,4,'DESCONTO DE CHEQUES','DSC CHQS');carregaCheques();return false;" >Voltar</a>
	<a href="#" class="botao" name="btnAlterar" id="btnAlterar" <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispA.'" onClick="return false;"'; } else { echo 'style="'.$dispA.'" onClick="mostraTelaAltera();return false;"'; } ?> >Alterar</a>
	<a href="#" class="botao" name="btnCancelar" id="btnCancelar" <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispX.'" onClick="return false;"'; } else { echo 'style="'.$dispX.'" onClick="showConfirmacao(\'Deseja cancelar o limite de desconto de cheques?\',\'Confirma&ccedil;&atilde;o - Aimaro\',\'cancelaLimiteDscChq()\',\'metodoBlock()\',\'sim.gif\',\'nao.gif\');return false;"'; } ?> >Cancelar</a>
	<a href="#" class="botao" name="btnConsultar" id="btnConsultar" <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispC.'" onClick="return false;"'; } else { echo 'style="'.$dispC.'" onClick="carregaDadosConsultaLimiteDscChq(\'C\');return false;"'; } ?> >Consultar</a>
	<a href="#" class="botao" name="btnExcluir" id="btnExcluir" <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispE.'" onClick="return false;"'; } else { echo 'style="'.$dispE.'" onClick="showConfirmacao(\'Deseja excluir o limite de desconto de cheques?\',\'Confirma&ccedil;&atilde;o - Aimaro\',\'excluirLimiteDscChq()\',\'metodoBlock()\',\'sim.gif\',\'nao.gif\');return false;"'; } ?> >Excluir</a>
	<div style="height: 3px;"></div>
	<a href="#" class="botao" name="btnIncluir" id="btnIncluir" <?php if (!in_array("I",$glbvars["opcoesTela"])) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } else { echo 'onClick="carregaDadosInclusaoLimiteDscChq(1);return false;"'; } ?> >Incluir</a>
	<a href="#" class="botao" name="btnImprimir" id="btnImprimir" <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispM.'" onClick="return false;"'; } else { echo 'style="'.$dispM.'" onClick="mostraImprimirLimite();return false;"'; } ?> >Imprimir</a>
	<a href="#" class="botao" name="btnConfNovLimite" id="btnConfNovLimite" style="<? echo $dispN ?>" onClick="carregaDadosConsultaLimiteDscChq('E');return false;">Efetivar</a>
	<a href="#" class="botao" name="btnUltimasAlteracoes" id="btnUltimasAlteracoes" onClick="ultimasAlteracoes();return false;">Últimas Alterações</a>
    
    <?
	if ($habrat == 'S') {
	?>
    <!-- 12/03/2019 -->
		<a href="#" class="botao" name="btnRatingMotor" id="btnRatingMotor" style="<? echo $dispL ?>" onClick="ratingMotor('2');">Analisar Rating</a>
    <!-- 12/03/2019 -->
    <?
    // 07/03/2019
    if ($permiteAlterarRating) {
    ?>
	<a href="#" class="botao" name="btnConfAlterarRating" id="btnConfAlterarRating" style="<? echo $dispT ?>" onClick="btnChequeRating();">Alterar Rating</a>
    <?
    }
    // 07/03/2019
	}
    ?>
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE CHEQUES - LIMITE");

formataLayout('divLimites');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
	
	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
	if (executandoProdutos == true) {
		
		$("#btnIncluir", "#divBotoesChequesLimite").click();
		
	}
	
</script>
<script type="text/javascript" src="descontos/desconto_rating.js?keyrand=<?php echo mt_rand(); ?>"></script>
