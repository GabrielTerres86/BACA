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

				 18/04/2018 - Alteração da coluna 'contrato' para 'prospota', inclusão da coluna 'contrato' (Leonardo Oliveira - GFT).

				 19/04/2018 - Adição do parâmetro 'nrctrmnt' ao ser selecionado uma proposta.  (Leonardo Oliveira - GFT).

				 
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
	require_once("../../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}
	
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
						
						$pr_inctrmnt = getByTagName($limites[$i]->tags,"inctrmnt");//9
						$pr_insitlim = getByTagName($limites[$i]->tags,"insitlim");//9

						$mtdClick = "selecionaLimiteTitulosProposta('"
							.($i + 1)."', '"
							.$qtLimites."', '"
							.$pr_nrctrlim."', '"
							.$pr_insitlim."', '"
							.$pr_dssitlim."', '"
							.$pr_dssitest."', '"
							.$pr_dssitapr."', '"
							.$pr_vllimite."', '"
							.$pr_nrctrmnt."', '"
							.$pr_inctrmnt."');";

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
						
						<td width="110px"><? echo $pr_dssitest; ?></td>

						<td><? echo $pr_dssitapr; ?></td>

					</tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>

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
			echo 'onClick="return false;';
		} else {
			echo 'onClick="carregaDadosAlteraLimiteDscTitPropostas();return false;"';
		} ?> />
	

	<input
		type="button"
		class="botao"
		value="Cancelar"
		id="btnAceitarRejeicao"
		name="btnAceitarRejeicao"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;';
		} else {
			echo 'onClick="aceitarRejeicao(0, \'PROPOSTA\');"';
		} ?>/>	

	<input 
		type="button"
		class="botao"
		value="Consultar"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;';
		} else {
			echo 'style="'.$dispC.'" onClick="carregaDadosConsultaPropostaDscTit();return false;"';
		} ?> />


	<input 
		type="button"
		class="botao"
		value="Incluir"
		id="btnIncluirLimite"
		name="btnIncluirLimite"
	  	onClick="carregaDadosInclusaoLimiteDscTit(1,'PROPOSTA');return false;"; 
 		/>



	<input 
		type="button"
		class="botao"
		value="Imprimir"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;';
		} else {
			echo '" onClick="mostraImprimirLimite(\'PROPOSTA\');return false;"';
		} ?> />
	


	<input 
		type="button"
		class="botao"
		value="Analisar"
		id="btnAnalisarLimite"
		name="btnAnalisarLimite"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;';
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
			echo 'onClick="return false;';
		} else { 
			echo 'onClick="carregaDadosDetalhesProposta(\'PROPOSTA\', nrcontrato, nrproposta);return false;"'; 
		} ?>/>
	

	<input 
		type="button"
		class="botao"
		value="Efetivar Limite"
		id="btnEfetivarLimite"
		name="btnEfetivarLimite"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;';
		} else {
			echo 'onClick="efetuarNovoLimite();"';
		} ?>/>
	

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