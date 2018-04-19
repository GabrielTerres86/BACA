<?php 

	/************************************************************************
	 Fonte: titulos_limite.php                                        
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                �ltima Altera��o: 26/06/2017
	                                                                  
	 Objetivo  : Mostrar opcao Limites de descontos da rotina         
	             Descontos da tela ATENDA                 		   	  
	                                                                  	 
	 Altera��es: 09/06/2010 - Mostrar descri��o da situa��o (David).

				 25/06/2010 - Mostar campo de envio a sede (Gabriel).
				 
				 12/07/2011 - Alterado para layout padr�o (Gabriel Capoia - DB1)
				 
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				 
				 21/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
 							  de proposta de novo limite de desconto de titulo para
 							  menores nao emancipados (Reinert).

				 17/12/2015 - Edi��o de n�mero do contrato de limite (Lunelli - SD 360072 [M175])

				 26/06/2017 - Ajuste para rotina ser chamada atrav�s da tela ATENDA > Produtos (Jonata - RKAM / P364).

				 28/08/2018 - Adaptado arquivo para Porpostas. Andre Avila.

				 15/04/2018 - Altera��o no bot�o 'Detalhes da Proposta' (Leonardo Oliveira - GFT).

				 18/04/2018 - Altera��o da coluna 'contrato' para 'prospota', inclus�o da coluna 'contrato' (Leonardo Oliveira - GFT).

	************************************************************************/
	
	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS - LIMITE");

	// Carrega permiss�es do operador
	include("../../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n�mero da conta � um inteiro v�lido
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


	// Se ocorrer um erro, mostra cr�tica
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
?>

<div id="divPropostas">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Data Proposta</th>
					<th>Contrato</th>
					<th>Proposta</th>
					<th>Valor Limite</th>
					<th>Dias de Vig&ecirc;ncia</th>
					<th>Linha de Desconto</th>
					<th >Situa&ccedil;&atilde;o da Proposta</th>
					<th>Situa&ccedil;&atilde;o da An&aacute;lise</th>
					<th>Decis&atilde;o</th>
				</tr>			
			</thead>
			<tbody>
				
				<?  for ($i = 0; $i < $qtLimites; $i++) {

						$pr_dtpropos = getByTagName($limites[$i]->tags,"dtpropos");//0
						$pr_nrctrlim = getByTagName($limites[$i]->tags,"nrctrlim");//1
						$pr_vllimite = getByTagName($limites[$i]->tags,"vllimite");//2
						$pr_qtdiavig = getByTagName($limites[$i]->tags,"qtdiavig");//3
						$pr_cddlinha = getByTagName($limites[$i]->tags,"cddlinha");//4
						$pr_dssitlim = getByTagName($limites[$i]->tags,"dssitlim");//5
						$pr_dssitest = getByTagName($limites[$i]->tags,"dssitest");//6
						$pr_dssitapr = getByTagName($limites[$i]->tags,"dssitapr");//7
						$pr_nrctrmnt = getByTagName($limites[$i]->tags,"nrctrmnt");//8

						$mtdClick = "selecionaLimiteTitulos('"
							.($i + 1)."', '"
							.$qtLimites."', '"
							.$pr_nrctrlim."', '"
							.$pr_dssitlim."', '"
							.$pr_dssitest."', '"
							.$pr_dssitapr."', '"
							.$pr_vllimite."');";				
				?>
					<tr id="trLimite<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">

						<td><? echo $pr_dtpropos; ?></td>

						<td>
							<span><? echo $pr_nrctrmnt; ?></span>
							<? echo formataNumericos('zzz.zzz.zzz',$pr_nrctrmnt,'.'); ?>
						</td>

						<td>
							<span><? echo $pr_nrctrlim; ?></span>
							<? echo formataNumericos('zzz.zzz.zzz',$pr_nrctrlim,'.'); ?>
						</td>
						
						<td>
              <? 
								$valor_retira_ponto_virgula = str_replace(",","",$pr_vllimite);
								$valor_retira_ponto_virgula = str_replace(".","",$valor_retira_ponto_virgula);
								$valor_formatado = formataNumericos('zzz.zz9,99',$valor_retira_ponto_virgula,'.,');
								echo $valor_formatado; 
							?>
						</td>

						<td><? echo $pr_qtdiavig; ?></td>
						
						<td><? echo $pr_cddlinha; ?></td>
						
						<td><? echo $pr_dssitlim; ?></td>
						
						<td><? echo $pr_dssitest; ?></td>

						<td><? echo $pr_dssitapr; ?></td>

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

<div id="divBotoesTitulosLimite" style="margin-bottom:10px;	margin-top: 10px;">
	
	<input 
		type="button"
		class="botao"
		value="Voltar"
		onClick="voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');carregaTitulos();return false;" />
	
	
	<input 
		type="button"
		class="botao"
		value="Alterar"
		<?php if ($qtLimites == 0){
			echo 'style="cursor: default;'.$dispA.'" onClick="return false;"';
		} else {
			echo 'style="'.$dispA.'" onClick="carregaDadosAlteraLimiteDscTitPropostas();return false;"';
		} ?> />
	

	<input
		type="button"
		class="botao"
		value="Cancelar"
		id="btnAceitarRejeicao"
		name="btnAceitarRejeicao"
		<?php if ($qtLimites == 0) {
			echo 'style="cursor: default;" onClick="return false;"';
		} else {
			echo 'onClick="aceitarRejeicao(0, \'PROPOSTA\');"';
		} ?>/>	

	<input 
		type="button"
		class="botao"
		value="Consultar"
		<?php if ($qtLimites == 0) {
			echo 'style="cursor: default;'.$dispC.'" onClick="return false;"';
		} else {
			echo 'style="'.$dispC.'" onClick="carregaDadosConsultaPropostaDscTit();return false;"';
		} ?> />


	<input 
		type="button"
		class="botao"
		value="Incluir"
		id="btnIncluirLimite"
		name="btnIncluirLimite"
	 	<?php if (!in_array("I",$glbvars["opcoesTela"])) { 
	 		echo 'style="cursor: default;display:none;" onClick="return false;"';
	  	} else { 
	  		echo 'onClick="carregaDadosInclusaoLimiteDscTit(1, \'PROPOSTA\');return false;"'; 
	  	} ?> />



	<input 
		type="button"
		class="botao"
		value="Imprimir"
		<?php if ($qtLimites == 0) {
			echo 'style="cursor: default;'.$dispM.'" onClick="return false;"';
		} else {
			echo 'style="'.$dispM.'" onClick="mostraImprimirLimite(\'PROPOSTA\');return false;"';
		} ?> />
	


	<input 
		type="button"
		class="botao"
		value="Analisar"
		id="btnAnalisarLimite"
		name="btnAnalisarLimite"
		<?php if ($qtLimites == 0) {
			echo 'style="cursor: default;" onClick="return false;"';
		} else {
			echo 'onClick="confirmaEnvioAnalise();return false;"'; 
		} ?>/>
	


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
	

	<input 
		type="button"
		class="botao"
		value="Efetivar Limite"
		id="btnEfetivarLimite"
		name="btnEfetivarLimite"
		<?php if ($qtLimites == 0) {
			echo 'style="cursor: default;" onClick="return false;"';
		} else {
			echo 'onClick="efetuarNovoLimite();"';
		} ?>/>
	

</div>

<script type="text/javascript">

	dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

	// Muda o t�tulo da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - LIMITE");

	formataLayout('divPropostas');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte�do que est� �tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
		
	//Se esta tela foi chamada atrav�s da rotina "Produtos" ent�o acessa a op��o conforme definido pelos respons�veis do projeto P364
	if (executandoProdutos == true) {
		
		$("#btnIncluirLimite", "#divBotoesTitulosLimite").click();
		
	}

</script>