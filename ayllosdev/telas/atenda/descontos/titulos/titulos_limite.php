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
	
	// Monta o xml de requisição
	$xmlGetLimites  = "";
	$xmlGetLimites .= "<Root>";
	$xmlGetLimites .= "	<Cabecalho>";
	$xmlGetLimites .= "		<Bo>b1wgen0030.p</Bo>";
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

	//print_r($limites);
	
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
					<th >Situa&ccedil;&atilde;o do Limite</th>
					<th>Situa&ccedil;&atilde;o da An&aacute;lise</th>
					<th>Decis&atilde;o</th>
				</tr>			
			</thead>
			<tbody>
				<?  for ($i = 0; $i < $qtLimites; $i++) {
						

						$mtdClick = "selecionaLimiteTitulos('".($i + 1)."', '".$qtLimites."', '".($limites[$i]->tags[3]->cdata)."', '".($limites[$i]->tags[7]->cdata)."', '".($limites[$i]->tags[8]->cdata)."', '".($limites[$i]->tags[9]->cdata)."', '".($limites[$i]->tags[2]->cdata)."');";
									
				?>
					<tr id="trLimite<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
						<td><? echo getByTagName($limites[$i]->tags,"DTPROPOS"); ?></td>
						
						<td><? echo $limites[$i]->tags[1]->cdata; ?></td>
						
						<td><span><? echo $limites[$i]->tags[3]->cdata; ?></span>
							<? echo formataNumericos('zzz.zzz.zzz',$limites[$i]->tags[3]->cdata,'.'); ?></td>
						
						<td><span><? echo $limites[$i]->tags[2]->cdata; ?></span>
							<? echo number_format(str_replace(",",".",$limites[$i]->tags[2]->cdata),2,",","."); ?></td>
						
						<td><? echo $limites[$i]->tags[4]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[5]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[7]->cdata; ?></td>
						
						<td><? echo $limites[$i]->tags[8]->cdata; ?></td>

						<td><? echo $limites[$i]->tags[9]->cdata; ?></td>
												
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
	<input type="button" class="botao gft" value="Voltar"  onClick="voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');carregaTitulos();return false;" />
	<input type="button" class="botao gft" value="Alterar"  <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispA.'" onClick="return false;"'; } else { echo 'style="'.$dispA.'" onClick="carregaDadosAlteraLimiteDscTit();return false;"'; } ?> />
	<input type="button" class="botao gft" value="Cancelar"  <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispX.'" onClick="return false;"'; } else { echo 'style="'.$dispX.'" onClick="showConfirmacao(\'Deseja cancelar o limite de desconto de t&iacute;tulos?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'cancelaLimiteDscTit()\',\'metodoBlock()\',\'sim.gif\',\'nao.gif\');return false;"'; } ?>  />
	<input type="button" class="botao gft" value="Consultar"  <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispC.'" onClick="return false;"'; } else { echo 'style="'.$dispC.'" onClick="carregaDadosConsultaLimiteDscTit();return false;"'; } ?> />
	<input type="button" class="botao gft" value="Excluir"  <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispE.'" onClick="return false;"'; } else { echo 'style="'.$dispE.'" onClick="showConfirmacao(\'Deseja excluir o limite de desconto de t&iacute;tulos?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'excluirLimiteDscTit()\',\'metodoBlock()\',\'sim.gif\',\'nao.gif\');return false;"'; } ?> />
	<input type="button" class="botao gft" value="Incluir" id="btnIncluirLimite" name="btnIncluirLimite" <?php if (!in_array("I",$glbvars["opcoesTela"])) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } else { echo 'onClick="carregaDadosInclusaoLimiteDscTit(1);return false;"'; } ?> />
	<input type="button" class="botao gft" value="Analisar"  id="btnAnalisarLimite" name="btnAnalisarLimite" <?php if ($qtLimites == 0) { echo 'style="cursor: default;" onClick="return false;"'; } else { echo 'onClick="confirmaEnvioAnalise();"'; } ?>/>
	<input type="button" class="botao gft" value="Imprimir" <?php if ($qtLimites == 0) { echo 'style="cursor: default;'.$dispM.'" onClick="return false;"'; } else { echo 'style="'.$dispM.'" onClick="mostraImprimirLimite();return false;"'; } ?> />
	<input type="button" class="botao gft" value="Detalhes Proposta"  id="btnDetalhesProposta" name="btnDetalhesProposta" <?php if ($qtLimites == 0) { echo 'style="cursor: default;" onClick="return false;"'; } else { echo 'onClick="carregaDadosDetalhesProposta();return false;"'; } ?>/>
	<input type="button" class="botao gft" value="Confirmar Novo Limite"  id="btnConfirmarNovoLimite" name="btnConfirmarNovoLimite" <?php if ($qtLimites == 0) { echo 'style="cursor: default;" onClick="return false;"'; } else { echo 'onClick="confirmarNovoLimite();"'; } ?>/>
	<input type="button" class="botao gft" value="Negar"  id="btnAceitarRejeicao" name="btnAceitarRejeicao" <?php if ($qtLimites == 0) { echo 'style="cursor: default;" onClick="return false;"'; } else { echo 'onClick="aceitarRejeicao();"'; } ?>/>	
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - LIMITE");

formataLayout('divLimites');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
	
	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
	if (executandoProdutos == true) {
		
		$("#btnIncluirLimite", "#divBotoesTitulosLimite").click();
		
	}


</script>