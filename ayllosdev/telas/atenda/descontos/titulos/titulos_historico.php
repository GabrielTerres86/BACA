<?php 

	/***************************************************************************
	 Fonte: titulos.php
	 Autor: Guilherme
	 Data : Novembro/2008                 Última Alteração: 25/04/2018

	 Objetivo  : Mostrar opção Títulos da Rotina de Desconto de Títulos

	 Alterações: 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				 
				 09/07/2012 - Inclusão de campos no form para listagem de 
                              informações de títulos descontados com e sem
                              registro (Lucas).

                 26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).

                 07/03/2018 - Novo campo 'Data Renovação' (Leonardo Oliveira - GFT)

                 13/03/2018 - Ajuste nos botões da tela, novo campo 'Renovação' e novo input perrenov do tipo hidden. (Leonardo Oliveira - GFT)

				 16/03/2018 - Novos campos flgstlcr e cddlinha, ambos do tipo hidden. (Leonardo Oliveira - GFT)

				 28/03/2018 - Novos botões Contratos e Propostas. (Andre Avila - GFT)

				 12/04/2018 - Criação do botão manutenção e ajuste no tamanho da tela. (Leonardo Oliveira - GFT)

 				 25/04/2018 - Alterado o comportamento dos botões na <div id="divBotoes" >, por definicção do cliente os mesmos devem ser ocultados caso o usuário não possua permissão. (Andre Avila - GFT)

				 07/05/2018 - Adicionada verificação para definir se o bordero vai seguir o fluxo novo ou o antigo (Luis Fernando - GFT)

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
	
	setVarSession("nmrotina","DSC TITS");
	
	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se os parêmetros necessários foram informados
	if (!isset($_POST["nrdconta"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	/*Verifica se o borderô deve ser utilizado no sistema novo ou no antigo*/
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "     <tpctrlim>3</tpctrlim>";
	$xml .= "     <nrctrlim>0</nrctrlim>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","LISTAR_HIST_ALT_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
	$root = $xmlObj->roottag;
	// Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
		exit;
	}
	$dados = $root->dados;

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>
<div id="divTitulosUltAlteracoes">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Contrato</th>
					<th>In&iacute;cio</th>
					<th>Fim</th>
					<th>Limite</th>
					<th>Situa&ccedil;&atilde;o</th>
					<th>Data Situa&ccedil;&atilde;o</th>
					<th>Motivo</th>
				</tr>			
			</thead>
			<tbody>
				<?php foreach($dados->find("inf") as $t) {?>
					<tr>
						<td><?=$t->nrctrlim;?></td>
						<td><?=$t->dtinivig;?></td>
						<td><?=$t->dtfimvig;?></td>
						<td><?=$t->vllimite;?></td>
						<td><?=$t->dssitlim;?></td>
						<td><?=$t->dhalteracao;?></td>
						<td><?=$t->dsmotivo;?></td>
					</tr>
				<?php } ?>
			</tbody>
		</table>
	</div>
</div>

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao1","divConteudoOpcao");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS");

	formataLayout('divTitulosUltAlteracoes');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>