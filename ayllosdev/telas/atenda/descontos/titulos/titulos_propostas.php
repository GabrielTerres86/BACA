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

                     26/04/2018 - Ajuste nos valores retornados ao buscar propostas (Leonardo Oliveira - GFT).

                     26/04/2018 - Ajuste na funcao de chamada da proposta e manutencao (Vitor Shimada Assanuma - GFT)

                     14/08/2018 - Incluido novo botao 'Anular'. PRJ 438 (Mateus Z - Mouts)

                     14/02/2019 - P450 - Inclusão dos campos nota do rating, origem da nota do rating e Status  (Luiz Otávio Olinger Momm - AMCOM)
                 
                     07/03/2019 - P450 - Inclusão da consulta do parametro se a coopoerativa pode Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM).
                 
                     15/03/2019 - P450 - Inclusão da consulta Rating (Luiz Otávio Olinger Momm - AMCOM).
                 
                     08/04/2019 - P450 - Ajustes de interface conforme solicitação Ailos (Luiz Otávio Olinger Momm - AMCOM).

                     25/04/2019 - P450 - Ajustes de interface conforme solicitação Ailos (Luiz Otávio Olinger Momm - AMCOM).

                     13/05/2019 - P450 - Não mostrar Rating quando estiver como situação "não analisado" (Luiz Otávio Olinger Momm - AMCOM).

                     24/05/2019 - P450 - Removido mensageiria para pesquisa de rating por proposta (Luiz Otávio Olinger Momm - AMCOM).

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
	
	setVarSession("nmrotina","DSC TITS - PROPOSTA");

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

	$xmlResult = mensageria(
		$xmlGetLimites,
		$pakage,
		$procedure_acao,
		$glbvars["cdcooper"],
		$glbvars["cdagenci"],
		$glbvars["nrdcaixa"],
		$glbvars["idorigem"],
		$glbvars["cdoperad"],
		"</Root>");

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

?>

<div id="divPropostas">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Data<br>Proposta</th>
					<th>Contrato</th>
					<th>Proposta</th>
					<th>Valor<br>Limite</th>
					<th title="Dias Vig&ecirc;ncia">Vig</th>
					<th title="Linha Desconto">LD</th>
					<th>Situa&ccedil;&atilde;o<br>Proposta</th>
					<th>Situa&ccedil;&atilde;o<br>An&aacute;lise</th>
					<th>Decis&atilde;o</th>
					<!-- [14/02/2019] -->
					<th><? echo utf8ToHtml('Nota Rating');?></th>
					<th title="Origem"><? echo utf8ToHtml('Retorno');?></th>
					<!-- [14/02/2019] -->
				</tr>
			</thead>
			<tbody>

				<?  for ($i = 0; $i < $qtLimites; $i++) {

						$pr_dtpropos = getByTagName($limites[$i]->tags,"dtpropos");//0  data da proposta
						$pr_nrctrlim = getByTagName($limites[$i]->tags,"nrctrlim");//1  contrato
						$pr_vllimite = getByTagName($limites[$i]->tags,"vllimite");//2  valor do limite
						$pr_qtdiavig = getByTagName($limites[$i]->tags,"qtdiavig");//3  quantidade de dias de vigência
						$pr_cddlinha = getByTagName($limites[$i]->tags,"cddlinha");//4  codigo da linha de desconto
						$pr_nrctrmnt = getByTagName($limites[$i]->tags,"nrctrmnt");//5  contrato
						
						$pr_dssitlim = getByTagName($limites[$i]->tags,"dssitlim");//6  desc situação da proposta
						$pr_dssitest = getByTagName($limites[$i]->tags,"dssitest");//7  desc situação da analise
						$pr_dssitapr = getByTagName($limites[$i]->tags,"dssitapr");//8  desc decisão

						$pr_insitlim = getByTagName($limites[$i]->tags,"insitlim");//9  cod situação da proposta
						$pr_insitest = getByTagName($limites[$i]->tags,"insitest");//10 cod situação da analise
						$pr_insitapr = getByTagName($limites[$i]->tags,"insitapr");//11 cod decisão

						$pr_inctrmnt = getByTagName($limites[$i]->tags,"inctrmnt");//12

                
						/* 15/03/2019 */
						$msgErro = '';
						$notaRating = getByTagName($limites[$i]->tags,"inrisrat");;
						$origemRating = getByTagName($limites[$i]->tags,"origerat");;
						$situacaoRating = '';
						/* 15/03/2019 */
                
						$mtdClick = "selecionaLimiteTitulosProposta('"
							.($i + 1)."', '" 		// id linha
							.$qtLimites."', '" 		// qtd de propostas
							.$pr_nrctrlim."', '" 	// limite
							.$pr_vllimite."', '"	// valor do limite
							.$pr_nrctrmnt."', '"	// contrato
							.$pr_dssitlim."', '" 	// desc situação da proposta
							.$pr_dssitest."', '"	//desc situação da analise
							.$pr_dssitapr."', '"	// desc decisão
							.$pr_insitlim."', '" 	// cod situação da proposta
							.$pr_insitest."', '" 	// cod situação da analise
							.$pr_insitapr."', '"
							.$pr_inctrmnt."');";	// cod decisão
			
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
						
						<td><? echo stringTabela($pr_dssitlim, 20, 'primeira'); ?></td>

						<td title="<?=stringTabela($pr_dssitest, 50, 'primeira'); ?>"><? echo stringTabela($pr_dssitest, 20, 'primeira'); ?></td>

						<td title="<?=stringTabela($pr_dssitapr, 50, 'primeira'); ?>"><? echo stringTabela($pr_dssitapr, 20, 'primeira'); ?></td>

						<!-- [14/02/2019] -->
						<td><?=$notaRating?></td>
						<td title="<?=stringTabela($origemRating, 30, 'primeira'); ?>"><?=stringTabela($origemRating, 10, 'primeira'); ?></td>
						<!-- [14/02/2019] -->

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
		onClick="fecharRotinaGenerico('TITULOS'); return false;" />
	
	
	<input 
		type="button"
		class="botao"
		value="Alterar"
		<?php if ($qtLimites == 0){
			echo 'onClick="return false;"';
		} else {
			echo 'onClick="carregaDadosAlteraLimiteDscTitPropostas(); return false;"';
		} ?> />
	

	<input
		type="button"
		class="botao"
		value="Cancelar"
		id="btnAceitarRejeicao"
		name="btnAceitarRejeicao"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else {
			echo 'onClick="aceitarRejeicao(0, \'PROPOSTA\');"';
		} ?>/>	

	<input 
		type="button"
		class="botao"
		value="Consultar"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else {
			echo 'style="'.$dispC.'"';
			echo 'onClick="carregaDadosConsultaPropostaDscTit(\'C\'); return false;" ';
		} ?> />


	<input 
		type="button"
		class="botao"
		value="Incluir"
		id="btnIncluirLimite"
		name="btnIncluirLimite"
	  	onClick="carregaDadosInclusaoLimiteDscTit(1,'PROPOSTA'); return false;" />



	<input 
		type="button"
		class="botao"
		value="Imprimir"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else {
			echo 'onClick="mostraImprimirLimite(\'PROPOSTA\'); return false;"';
		} ?> />
	


	<input 
		type="button"
		class="botao"
		value="Analisar"
		id="btnAnalisarLimite"
		name="btnAnalisarLimite"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else {
			echo 'onClick="confirmaEnvioAnalise(); return false;"'; 
		} ?>/>
	


	<input 
		type="button" 
		class="botao" 
		value="Detalhes Propostas"  
		id="btnDetalhesProposta"
		name="btnDetalhesProposta" 
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else { 
			echo 'onClick="carregaDadosDetalhesProposta(\'PROPOSTA\', nrctrlim, nrctrmnt); return false;"'; 
		} ?>/>
	

	<input 
		type="button"
		class="botao"
		value="Efetivar"
		id="btnEfetivarLimite"
		name="btnEfetivarLimite"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else {
			echo 'onClick="carregaDadosConsultaPropostaDscTit(\'E\'); return false;" ';
		} ?>/>
	
	<input 
		type="button"
		class="botao"
		value="Anular"
		id="btnAnular"
		name="btnAnular"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else {
			echo 'onClick="carregaDadosConsultaMotivos();" ';
		} ?>/>	

    <?
    // 07/03/2019
    if ($permiteAlterarRating) {
    ?>

	<input 
		type="button"
		class="botao"
		value="Alterar Rating"
		id="btnAlterarRating"
		name="btnAlterarRating"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else {
			echo 'onClick="btnTituloPropostaRating();" ';
		} ?>
		/>
    <?
    }
    // 07/03/2019
    ?>

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
<script type="text/javascript" src="descontos/desconto_rating.js?keyrand=<?php echo mt_rand(); ?>"></script>