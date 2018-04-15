<?php 

	/************************************************************************
	 Fonte: titulos_limite.php                                        
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração: 26/06/2017
	                                                                  
	 Objetivo  : Mostrar opcao Limites de descontos da rotina         
	             Descontos da tela ATENDA                 		   	  
	                                                                  	 
	 Alterações: 09/06/2010 - Mostrar descrição da situação (David).

				 25/06/2010 - Mostar campo de envio a sede (Gabriel).
				 
				 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
				 
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				 
				 21/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
 							  de proposta de novo limite de desconto de titulo para
 							  menores nao emancipados (Reinert).

				 17/12/2015 - Edição de número do contrato de limite (Lunelli - SD 360072 [M175])

				 26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).

				 28/08/2018 - Adaptado arquivo para Porpostas. Andre Avila.

				 15/04/2018 - Alteração no botão 'Detalhes da Proposta' (Leonardo Oliveira - GFT).

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
	
	setVarSession("nmrotina","DSC TITS - LIMITE");

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
	

	$xmlGetLimites  = "";
	$xmlGetLimites .= "<Root>";
	$xmlGetLimites .= "	<Dados>";
	$xmlGetLimites .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetLimites .= "	</Dados>";
	$xmlGetLimites .= "</Root>";
		
$procedure_acao = 'OBTEM_DADOS_PROPOSTA';
$pakage = 'TELA_ATENDA_DESCTO';
$glbvars['rotinasTela'][8] = 'PROPOSTAS';


$xmlResult = mensageria($xmlGetLimites, $pakage, $procedure_acao,  $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

$xmlObjLimites = getObjectXML($xmlResult);


	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimites->roottag->tags[0]->name) == "ERRO") {

		exibeErro($xmlObjLimites->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$limites   = $xmlObjLimites->roottag->tags[0]->tags;
	$qtLimites = count($limites);


	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

	$insitlim = $limites[$i]->tags[7]->cdata;
	$dssitest = $limites[$i]->tags[8]->cdata;
	$insitapr = $limites[$i]->tags[9]->cdata;
	
?>

<?  for ($i = 0; $i < $qtLimites; $i++) {

?>
	<input type="hidden" id="vlLimite" name="vlLimite" value="<? echo $limites[$i]->tags[2]->cdata; ?>" />
	<input type="hidden" id="insitlim" name="insitlim" value="<? echo $limites[$i]->tags[7]->cdata; ?>" />
	<input type="hidden" id="dssitest" name="dssitest" value="<? echo $limites[$i]->tags[8]->cdata; ?>" />
	<input type="hidden" id="insitapr" name="insitapr" value="<? echo $limites[$i]->tags[9]->cdata; ?>" />

<?
}
?>


<div id="divPropostas">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Data Proposta</th>
					<!--<th>Ini.Vig&ecirc;n.</th>-->
					<th>Contrato</th>
					<th>Valor Limite</th>
					<th>Dias de Vig&acirc;ncia</th>
					<th>Linha de Desconto</th>
					<th >Situa&ccedil;&atilde;o da Proposta</th>
					<th>Situa&ccedil;&atilde;o da An&aacute;lise</th>
					<th>Decis&atilde;o</th>
				</tr>			
			</thead>
			<tbody>
				
				<?  for ($i = 0; $i < $qtLimites; $i++) {
						

						$mtdClick = "selecionaLimiteTitulos('".($i + 1)."', '".$qtLimites."', '".($limites[$i]->tags[1]->cdata)."', '".($limites[$i]->tags[7]->cdata)."', '".($limites[$i]->tags[8]->cdata)."', '".($limites[$i]->tags[9]->cdata)."', '".($limites[$i]->tags[2]->cdata)."');";
									
				?>
					<tr id="trLimite<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">

						<td><? echo getByTagName($limites[$i]->tags,"DTPROPOS"); ?></td>
						<td><? echo $limites[$i]->tags[1]->cdata; ?></td>

						<td><span>
						<? $valor_retira_ponto_virgula = str_replace(",","",$limites[$i]->tags[2]->cdata);
						$valor_retira_ponto_virgula = str_replace(".","",$valor_retira_ponto_virgula);
						$valor_formatado = formataNumericos('zzz.zz9,99',$valor_retira_ponto_virgula,'.,'); ?>
						 ?></span>
						<? echo $valor_formatado ?></td>

						<td><? echo $limites[$i]->tags[3]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[4]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[5]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[6]->cdata; ?></td>

						<td><? echo $limites[$i]->tags[7]->cdata; ?></td>
					</tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>

<?php
	$dispA = (!in_array("A",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispX = (!in_array("X",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispC = (!in_array("C",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispE = (!in_array("E",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispM = (!in_array("M",$glbvars["opcoesTela"])) ? 'display:none;' : '';
?>

<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	
	
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');carregaTitulos();return false;" />
	
	
	<input type="button" class="botao" value="Alterar"  <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispA.'" onClick="return false;"'; } else { echo 'style="'.$dispA.'" onClick="carregaDadosAlteraLimiteDscTitPropostas();return false;"'; } ?> />
	

	<input type="button" class="botao" value="Cancelar"  id="btnAceitarRejeicao" name="btnAceitarRejeicao" <?php if ($qtLimites == 0) { echo 'style="cursor: default;" onClick="return false;"'; } else { echo 'onClick="aceitarRejeicao(0, \'PROPOSTA\');"'; } ?>/>	

	<input type="button" class="botao" value="Consultar"  <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispC.'" onClick="return false;"'; } else { echo 'style="'.$dispC.'" onClick="carregaDadosConsultaPropostaDscTit();return false;"'; } ?> />


	<input type="button" class="botao" value="Incluir" id="btnIncluirLimite" name="btnIncluirLimite"
	 <?php if (!in_array("I",$glbvars["opcoesTela"])) { 
	 	echo 'style="cursor: default;display:none;" onClick="return false;"';
	  } else { 
	  	echo 'onClick="carregaDadosInclusaoLimiteDscTit(1, \'PROPOSTA\');return false;"'; 
	  	} ?> />



	<input type="button" class="botao" value="Imprimir" <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispM.'" onClick="return false;"'; } else { echo 'style="'.$dispM.'" onClick="mostraImprimirLimite(\'PROPOSTA\');return false;"'; } ?> />
	


	<input type="button" class="botao" value="Analisar"  id="btnAnalisarLimite" name="btnAnalisarLimite" <?php if ($qtLimites == 0) { echo 'style="cursor: default;" onClick="return false;"'; } else { echo 'onClick="confirmaEnvioAnalise();"'; } ?>/>
	


	<input 
		type="button" 
		class="botao" 
		value="Detalhes Propostas"  
		id="btnDetalhesProposta"
		name="btnDetalhesProposta" 
		<?php if ($qtLimites == 0) {
			echo 'style="cursor: default;" onClick="return false;"'; 
		} else { 
			echo 'onClick="carregaDadosDetalhesProposta(\'PROPOSTA\', nrcontrato);return false;"'; 
		} ?>/>
	

	<input type="button" class="botao" value="Efetivar Limite"  id="btnEfetivarLimite" name="btnEfetivarLimite" <?php if ($qtLimites == 0) { echo 'style="cursor: default;" onClick="return false;"'; } else { echo 'onClick="efetuarNovoLimite();"'; } ?>/>
	

</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - LIMITE");

formataLayout('divPropostas');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
	
	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
	if (executandoProdutos == true) {
		
		$("#btnIncluirLimite", "#divBotoesTitulosLimite").click();
		
	}
</script>