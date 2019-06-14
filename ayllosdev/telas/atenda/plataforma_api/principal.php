<?php 
//**********************************************************************************************//
//*** Fonte: principal.php                                                           		 ***//
//*** Autor: Andrey Formigari                                                                ***//
//*** Data : Fevereiro/2019                Última Alteração:                        		 ***//
//***                                                                                        ***//
//*** Objetivo  : Mostrar opcao Principal da rotina de Plataforma API da tela ATENDA 		 ***//
//****			                                                                             ***//
//***                                                                                        ***//
//*** Alter.:                                                                                ***//
//***															   	                         ***//
//**********************************************************************************************//

session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo metodo POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
	exibeErro($msgError);
}

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;

$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_API", "CONSULTA_SERVICOS_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',$msgErro,'Alerta - Aimaro','', false);
}

$cdsitsnh = $xmlObject->roottag->tags[0]->attributes['CDSITSNH'];
$cdsitconv = $xmlObject->roottag->tags[0]->attributes['CDSITCONV'];
$cdproddisp = $xmlObject->roottag->tags[0]->attributes['CDPRODDISP'];
$cdservdisp = $xmlObject->roottag->tags[0]->attributes['CDSERVDISP'];
$registros = $xmlObject->roottag->tags[0]->tags;
?>
<div class="divRegistros" style="height: 130px;">
	<input type="hidden" name="cdsitconv" id="cdsitconv" value="<?php echo $cdsitconv; ?>" />
	<input type="hidden" name="cdproddisp" id="cdproddisp" value="<?php echo $cdproddisp; ?>" />
	<input type="hidden" name="cdservdisp" id="cdservdisp" value="<?php echo $cdservdisp; ?>" />
	<table>
		<thead>
			<tr>
				<th style="width: 201px;"><? echo utf8ToHtml('Produto');?></th>
				<th style="width: 195px;"><? echo utf8ToHtml('Serviço');?></th>
				<th style="width: 100px;"><? echo utf8ToHtml('Adesão');?></th>
				<th style="width: 94px;"><? echo utf8ToHtml('Situação');?></th>
			</tr>
		</thead>		
		<tbody>
			<?
			foreach ($registros as $registro) {
				$cdproduto = getByTagName($registro->tags,'cdproduto');
				$dsproduto = getByTagName($registro->tags,'dsproduto');
				$dsservico = getByTagName($registro->tags,'dsservico_api');
				$dtadesao = getByTagName($registro->tags,'dtadesao');
				$idsituacao_adesao = getByTagName($registro->tags,'idsituacao_adesao');
				$rowid = getByTagName($registro->tags,'rowid');
				$idservico_api = getByTagName($registro->tags,'idservico_api');
			?>
			<tr>
				<td>
					<input type="hidden" name="cdproduto" id="cdproduto" value="<? echo $cdproduto; ?>" />
					<input type="hidden" name="dtadesao" id="dtadesao" value="<? echo $dtadesao; ?>" />
					<input type="hidden" name="idsituacao_adesao" id="idsituacao_adesao" value="<? echo $idsituacao_adesao; ?>" />
					<input type="hidden" name="rowid" id="rowid" value="<? echo $rowid; ?>" />
					<input type="hidden" name="idservico_api" id="idservico_api" value="<? echo $idservico_api; ?>" />
					<input type="hidden" name="convenio_ativo" id="convenio_ativo" value="<? echo $cdsitconv; ?>" />
					<input type="hidden" name="dsproduto_servico" id="dsproduto_servico" value="<? echo $dsservico; ?>" />
					<? echo $dsproduto; ?>
				</td>
				<td><? echo $dsservico; ?></td>
				<td><? echo $dtadesao; ?></td>
				<td><? echo ( ( $idsituacao_adesao ) ? 'Ativo' : 'Inativo' ); ?></td>
			</tr>
			<?
			}
			?>
		</tbody>
	</table>
</div>

<form action="<?php echo $UrlSite; ?>telas/atenda/plataforma_api/impressao_termo.php" name="frmTermo" class="formulario" id="frmTermo" method="post">
    <input type="hidden" id="dsrowid" name="dsrowid" value="">
    <input type="hidden" id="sidlogin" name="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<div id="divBotoes">
	<a class="botao" id="btVoltar" onclick="encerraRotina(true);return false;" href="#">Voltar</a>
	<a class="<?=(($cdsitsnh)?'botao':'botaoDesativado')?>" id="btIncluir" onclick="<?=(($cdsitsnh)?'controlaOperacao(\'I\');':'')?>return false;" href="#">Incluir</a>
	<a class="<?=((count($registros)>0)?'botao':'botaoDesativado')?>" id="btAlterar" onclick="<?=((count($registros)>0)?'controlaOperacao(\'A\');':'')?>return false;" href="#">Alterar</a>
	<a class="<?=((count($registros)>0)?'botao':'botaoDesativado')?>" id="btConsultar" onclick="<?=((count($registros)>0)?'controlaOperacao(\'C\');':'')?>return false;" href="#">Consultar</a>
	<a class="<?=((count($registros)>0)?'botao':'botaoDesativado')?>" id="btExcluir" onclick="<?=((count($registros)>0)?'controlaOperacao(\'E\');':'')?>return false;" href="#"><? echo utf8ToHtml('Excluir Serviço');?></a><br />
	<a class="botao" id="botaoCredenciaisAcesso" onclick="controlaOperacao('CA');return false;" href="#">Credencias de Acesso</a>
	<a class="<?=((count($registros)>0)?'botao':'botaoDesativado')?>" id="botaoImpressaoTermo" onclick="<?=((count($registros)>0)?'controlaOperacao(\'IT\');':'')?>return false;" style="margin-top: 5px;" href="#">Imprimir Termo</a>
</div>

<br style="clear: both;" />

<script type="text/javascript">
	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está atrás do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	controlaLayout('P');
</script>