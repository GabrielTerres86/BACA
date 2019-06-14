<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Formulário para Listar/Cadastrar/Alterar/Excluir um desenvolvedor.
 */
session_start();

$cddopcao = (!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cddesenvolvedor = (!empty($_POST['cddesenvolvedor'])) ? $_POST['cddesenvolvedor'] : '';
$isPlataformaAPI = (int) ((isset($_POST['isPlataformaAPI'])) ? $_POST['isPlataformaAPI'] : 0);
	
// Includes para controle da session, variaveis globais de controle, e biblioteca de funcoes
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
//require_once("../../includes/contola_secao.php");


// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();
// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '')
	exibirErro('error',$msgError,'Alerta - Aimaro','',false);

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cddesenvolvedor>".$cddesenvolvedor."</cddesenvolvedor>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADDES", "CONSULTA_DESENVOLVEDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    if ($cddesenvolvedor) exibirErro('error',utf8_encode(str_replace('"', "'", $msgErro)),'Alerta - Aimaro','$(\'#cddesen\').val(\'\').focus();',false);
}

$desenvolvedor = $xmlObj->roottag->tags[0]->tags[0];

$cddesenvolvedor = getByTagName($desenvolvedor->tags, "cddesenvolvedor");
$inpessoa = getByTagName($desenvolvedor->tags, "inpessoa");
$nrdocumento = getByTagName($desenvolvedor->tags, "nrdocumento");
$dsnome = getByTagName($desenvolvedor->tags, "dsnome");
$nrcep_endereco = getByTagName($desenvolvedor->tags, "nrcep_endereco");
$dsendereco = getByTagName($desenvolvedor->tags, "dsendereco");
$nrendereco = getByTagName($desenvolvedor->tags, "nrendereco");
$dscomplemento = getByTagName($desenvolvedor->tags, "dscomplemento");
$dsbairro = getByTagName($desenvolvedor->tags, "dsbairro");
$dscidade = getByTagName($desenvolvedor->tags, "dscidade");
$dsunidade_federacao = getByTagName($desenvolvedor->tags, "dsunidade_federacao");
$dsemail = getByTagName($desenvolvedor->tags, "dsemail");
$nrddd_celular = getByTagName($desenvolvedor->tags, "nrddd_celular");
$nrtelefone_celular = getByTagName($desenvolvedor->tags, "nrtelefone_celular");
$dscontato_celular = getByTagName($desenvolvedor->tags, "dscontato_celular");
$nrddd_comercial = getByTagName($desenvolvedor->tags, "nrddd_comercial");
$nrtelefone_comercial = getByTagName($desenvolvedor->tags, "nrtelefone_comercial");
$dscontato_comercial = getByTagName($desenvolvedor->tags, "dscontato_comercial");
$dsfrase = getByTagName($desenvolvedor->tags, "dsfrase_desenvolvedor");
$dsusuario_portal = getByTagName($desenvolvedor->tags, "dsusuario_portal");
$dschave = getByTagName($desenvolvedor->tags, "dschave");
?>

<form method="post" name="frmCadastroDesenvolvedor" id="frmCadastroDesenvolvedor" class="formulario">
	<div id="divDados" class="clsCampos">
	
		<fieldset style="padding: 5px">
			<legend><? echo utf8ToHtml('Informações do Desenvolvedor');?></legend>
			
			<label for="cddesen" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Código:');?></label>
			<input type="text" class="campo inteiro" id="cddesen" name="cddesen" style="width: 75px;" value="<?=$cddesenvolvedor?>" onkeydown="onKeyDownBuscaDesenvolvedor(event);" />
			<? if (!$cddesenvolvedor || $cddopcao == "C"){?>
			<a id="lupaDesenvolvedor" style="padding: 2px;cursor: pointer;" onclick="carregaPesquisaDesenvolvedor();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<? }else{ ?>
			<a id="lupaDesenvolvedor" style="padding: 2px;cursor: pointer;" onclick="return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<? } ?>
			
			<br style="clear:both"/>
			
			<label for="inpessoa" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Tipo de Pessoa:');?></label>
			<input style="background-color: transparent;" type="radio" onclick="$('#cpf_cnpj').addClass('cpf').removeClass('cnpj').val('').focus();layoutPadrao();$('label[for=\'cpf_cnpj\']').html('CPF:');" class="radio" id="inpessoa_f" name="inpessoa" value="1"<?=(($inpessoa==1)?' checked':'')?> /> <label for="inpessoa_f" style="margin-right: 10px;font-weight: 100;margin: 1px 8px 0 0;"><? echo utf8ToHtml('Física');?></label>
			<input style="background-color: transparent;" type="radio" onclick="$('#cpf_cnpj').addClass('cnpj').removeClass('cpf').val('').focus();layoutPadrao();$('label[for=\'cpf_cnpj\']').html('CNPJ:');" class="radio" id="inpessoa_j" name="inpessoa" value="2"<?=(($inpessoa==2)?' checked':'')?> /> <label for="inpessoa_j" style="font-weight: 100;margin: 1px 0 0 1px;"><? echo utf8ToHtml('Jurídica');?></label>
			
			<br style="clear:both"/>
			
			<label for="cpf_cnpj" class="clsCampos" style="width: 145px;"><?=(($inpessoa==2)?'CNPJ':(($inpessoa==1)?'CPF':'CPF/CNPJ'))?>:</label>
			<input type="text" onfocusout="$(this).removeClass('campoFocusIn');" class="campo<?=(($inpessoa==1)?' cpf': (($inpessoa==2)?' cnpj':''))?>" id="cpf_cnpj" name="cpf_cnpj" style="width: 135px;" value="<?=$nrdocumento?>" />
			
			<br style="clear:both"/>
			
			<label for="dsempresa" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Empresa:');?></label>
			<input type="text" class="campo" id="dsempresa" name="dsempresa" style="width: 446px;" value="<? echo $dsnome; ?>" maxlength="100" />
			
			<br style="clear:both"/>
			
			<label for="nrcep" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('CEP:');?></label>
			<input type="text" class="cep pesquisa campo" id="nrcep" name="nrcep" style="width: 100px;" value="<?=((!$nrcep_endereco) ? '' : formataCep($nrcep_endereco))?>" />
			<a id="lupa_cep" style="padding: 2px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			
			<br style="clear:both"/>
			
			<label for="dsendereco" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Endereço:');?></label>
			<input type="text" class="campo" id="dsendereco" name="dsendereco" style="width: 337px;" value="<? echo $dsendereco; ?>" maxlength="50" />
			
			<label for="nrendereco" class="clsCampos" style="width: 45px;"><? echo utf8ToHtml('N°:');?></label>
			<input type="text" class="campo inteiro" id="nrendereco" name="nrendereco" style="width: 60px;" value="<?=$nrendereco?>" maxlength="10" />
			
			<br style="clear:both"/>
			
			<label for="dscomplemento" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Complemento:');?></label>
			<input type="text" class="campo" id="dscomplemento" name="dscomplemento" style="width: 337px;" value="<? echo $dscomplemento; ?>" maxlength="50" />
			
			<label for="dsuf" class="clsCampos" style="width: 45px;"><? echo utf8ToHtml('UF:');?></label>
			<? echo selectEstado('dsuf', $dsunidade_federacao, 1) ?>
			
			<br style="clear:both"/>
			
			<label for="dscidade" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Cidade:');?></label>
			<input type="text" class="campo" id="dscidade" name="dscidade" style="width: 189px;" value="<? echo $dscidade; ?>" maxlength="50" />
			
			<label for="dsbairro" class="clsCampos" style="width: 65px;"><? echo utf8ToHtml('Bairro:');?></label>
			<input type="text" class="campo" id="dsbairro" name="dsbairro" style="width: 189px;" value="<? echo $dsbairro; ?>" maxlength="40" />
			
			<br style="clear:both"/>
			
			<label for="dsemail" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('E-mail:');?></label>
			<input type="text" class="campo" id="dsemail" name="dsemail" style="width: 446px;" value="<?=$dsemail?>" maxlength="100" />
			
			<br style="clear:both"/>
			
			<label for="nrddd_celular" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Telefone Celular:');?></label>
			<input type="text" class="campo inteiro" id="nrddd_celular" name="nrddd_celular" style="width: 30px;" maxlength="2" value="<?=$nrddd_celular?>" />
			<input type="text" class="campo inteiro" id="nrtelcelular" name="nrtelcelular" style="width: 120px;" maxlength="10" value="<?=$nrtelefone_celular?>" />
			
			<label for="dscontatocel" class="clsCampos" style="width: 70px;"><? echo utf8ToHtml('Contato:');?></label>
			<input type="text" class="campo" id="dscontatocel" name="dscontatocel" style="width: 220px;" value="<? echo $dscontato_celular; ?>" maxlength="30" />
			
			<br style="clear:both"/>
			
			<label for="nrddd_comercial" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Telefone Comercial:');?></label>
			<input type="text" class="campo inteiro" id="nrddd_comercial" name="nrddd_comercial" style="width: 30px;" maxlength="2" value="<?=$nrddd_comercial?>" />
			<input type="text" class="campo inteiro" id="nrtelcomercial" name="nrtelcomercial" style="width: 120px;" maxlength="10" value="<?=$nrtelefone_comercial?>" />
			
			<label for="dscontatocom" class="clsCampos" style="width: 70px;"><? echo utf8ToHtml('Contato:');?></label>
			<input type="text" class="campo" id="dscontatocom" name="dscontatocom" style="width: 220px;" value="<? echo $dscontato_comercial; ?>" maxlength="30" />
		</fieldset>
	
	</div>
</form>

<?php
	if ($cddopcao != "I") {
		include("form_frase_desenvolvedor.php");
	}
?>

<? if ($cddopcao == "I") { ?>
<div id="divBotoes" class="divBotoesPrincipal" style="margin-bottom: 10px;">
	<? if ($isPlataformaAPI == 1) { ?>
	<a class="botao" id="btVoltar" href="#" onclick="parent.voltaPesquisaDesenvolvedor(); return false;">Voltar</a>
	<? }else{ ?>
	<a class="botao" id="btVoltar" href="#" onclick="estadoInicial(); return false;">Voltar</a>
	<? } ?>
	<a class="botao" id="btConfirmar" href="#" onclick="confirmaCadastroDesenvolvedor(false)">Confirmar</a>
</div>
<? } ?>

<script type="text/javascript">
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	
	layoutPadrao();
	
	controlaLayout('<?=$cddopcao?>');
	
	// consultar e depois Alterar
	<? if ($cddesenvolvedor > 0 && $cddopcao == "A"){ ?>
	controlaLayout('AC');
	<? } ?>
	
	// consultar e depois excluir
	<? if ($cddesenvolvedor > 0 && $cddopcao == "E"){ ?>
	controlaLayout('CE');
	<? } ?>
	
	$('#dsuf', '#frmCadastroDesenvolvedor').addClass('campo').css({'width':'60px'});
	
	// Definindo as variáveis
    var bo = 'b1wgen0059.p';
    var procedure = '';
    var titulo = '';
    var qtReg = '';
    var filtrosPesq = '';
    var filtrosDesc = '';
    var colunas = '';
    var camposOrigem = 'nrcep;dsendereco;nrendereco;dscomplemento;nrcxapst;dsbairro;dsuf;dscidade';
	
	var linkEnderecoFisico = $('#lupa_cep', '#frmCadastroDesenvolvedor');
    if (linkEnderecoFisico.prev().hasClass('campoTelaSemBorda')) {
        linkEnderecoFisico.addClass('lupa').css('cursor', 'auto');
    } else {
        linkEnderecoFisico.css('cursor', 'pointer');
        linkEnderecoFisico.prev().buscaCEP('frmCadastroDesenvolvedor', camposOrigem, $('#divTela'));
    }

</script>