<?
/*************************************************************************
	Fonte: consulta.php
	Autor: Tiago 						Ultima atualizacao: 
	Data : Julho/2017
	
	Objetivo: Tela para visualizar a consulta/habilitacao/alteracao da 
	          rotina.
	
	Alteracoes: 
*************************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

$cddopcao    = trim($_POST["cddopcao"]);
$nrdconta    = $_POST['nrdconta'];

// Monta o xml para a requisicao
$xmlGetDadosTitulos  = "";
$xmlGetDadosTitulos .= "<Root>";
$xmlGetDadosTitulos .= " <Cabecalho>";
$xmlGetDadosTitulos .= "   <Bo>b1wgen0192.p</Bo>";
$xmlGetDadosTitulos .= "   <Proc>verif-aceite-conven</Proc>";
$xmlGetDadosTitulos .= " </Cabecalho>";
$xmlGetDadosTitulos .= " <Dados>";
$xmlGetDadosTitulos .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlGetDadosTitulos .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlGetDadosTitulos .= " </Dados>";
$xmlGetDadosTitulos .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetDadosTitulos);

// Cria objeto para classe de tratamento de XML
$xmlObjDadosTitulos = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjDadosTitulos->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosTitulos->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

// Seta a tag de arquivos para a variavel
$arquivos = $xmlObjDadosTitulos->roottag->tags[0]->tags;

$dscritic = $xmlObjDadosTitulos->roottag->tags[0]->attributes["DSCRITIC"];
$flconven = $xmlObjDadosTitulos->roottag->tags[0]->attributes["FLCONVEN"];


$cdopehom = getByTagName($arquivos[0]->tags,'cdopehom');
$dtaltera = getByTagName($arquivos[0]->tags,'dtaltera');
$nrremret = getByTagName($arquivos[0]->tags,'nrremret');


$nrconven =  getByTagName($arquivos[0]->tags,'nrconven');
$dtdadesa =  getByTagName($arquivos[0]->tags,'dtdadesa');
$cdoperad =  getByTagName($arquivos[0]->tags,'cdoperad');
$flgativo =  getByTagName($arquivos[0]->tags,'flgativo');
$dsorigem =  getByTagName($arquivos[0]->tags,'dsorigem');
$flghomol =  getByTagName($arquivos[0]->tags,'flghomol');
$dtdhomol =  getByTagName($arquivos[0]->tags,'dtdhomol');
$idretorn =  getByTagName($arquivos[0]->tags,'idretorn');


// Montar o xml de Requisicao para buscar os email da crapcem
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PGTA0001", "CARREGACRAPCEM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
    echo "showError('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);";    
}else{    
    $crapcem = $xmlObject->roottag->tags[0]->tags;
}    

// Montar o xml de Requisicao para buscar os email da crapcem
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PGTA0001", "CARREGACPTCEM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
    echo "showError('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);";    
}else{    
    $cptcem = $xmlObject->roottag->tags[0]->tags;
}    


if($cddopcao == 'I'){
    $dstitulo = "INCLUIR";
	$nrconven    = 1;
	$cdoperad    = $glbvars['cdoperad'].' - '.$glbvars['nmoperad'];
	$dtaltera    = $glbvars['dtmvtolt'];
	$dtdadesa	 = $glbvars['dtmvtolt'];
	//$cdopehom	 = $glbvars['cdoperad'].' - '.$glbvars['nmoperad'];
}else{
	if($cddopcao == 'A'){
		$dstitulo = "ALTERAR";
		$nrconven    = 1;
		$cdoperad    = $glbvars['cdoperad'].' - '.$glbvars['nmoperad'];
		$dtaltera    = $glbvars['dtmvtolt'];		
	}else{
		$dstitulo = "CONSULTA";
	}
}

?>

<script type="text/javascript">

function fnConfirmaInclusao(){
	
	var lstemail = $.map($('#dsemailadd option'), function(e) { return e.value; }).join(';');
	
	confirmaInclusao($('#nrconven','#frmConsulta').val(), $('#flghomol','#frmConsulta').val(), '<?php echo $glbvars['cdoperad'] ?>', $('#idretorn','#frmConsulta').val(), $('#flgativo','#frmConsulta').val(), lstemail);
	return false;
}

function fnConfirmaAlteracao(){
	var lstemail = $.map($('#dsemailadd option'), function(e) { return e.value; }).join(';');
	
	confirmaAlteracao($('#nrconven','#frmConsulta').val(), $('#flghomol','#frmConsulta').val(), '<?php echo $glbvars['cdoperad'] ?>', $('#idretorn','#frmConsulta').val(), $('#flgativo','#frmConsulta').val(), lstemail);
	return false;
}

function buscaOperador(){
	if( $('#flghomol','#frmConsulta').val() == 0 ){
	  $('#cdopehom','#frmConsulta').val('');
	}else{
	  $('#cdopehom','#frmConsulta').val('<?php echo $glbvars['cdoperad'].' - '.$glbvars['nmoperad']; ?>');
	}
}

$(document).ready(function(){
	$('#flghomol','#frmConsulta').unbind().bind('change',function(){buscaOperador();});		
});

</script>


<style type="text/css">
.popbox {
    position: absolute;
    z-index: 99999;
    width: 400px;
    padding: 5px;
    background: #CED3C6;
    color: #000000;
    margin: 0px;
    -webkit-box-shadow: 0px 0px 5px 0px rgba(164, 164, 164, 1);
    box-shadow: 0px 0px 5px 0px rgba(164, 164, 164, 1);
}
</style>

<form action="" name="frmConsulta" id="frmConsulta" method="post">

	<fieldset>
		<legend><? echo utf8ToHtml($dstitulo) ?></legend>
                <div id="divAba0" class="clsAbas">
                    <label for="nrconven"><? echo utf8ToHtml('Convênio:') ?></label>
                    <input name="nrconven" id="nrconven" class="campoTelaSemBorda" readonly value="<?php echo formataNumericos("zz.zzz.zz9",$nrconven,'.'); ?>" />
                    <br />
                    <label for="dtdadesa"><? echo utf8ToHtml('Adesão:') ?></label>
                    <input name="dtdadesa" id="dtdadesa" class="campoTelaSemBorda" readonly value="<?php echo $dtdadesa; ?>" />
                    <br />
                    <label for="flgativo"><? echo utf8ToHtml('Situação:') ?></label>               
                    <select name="flgativo" id="flgativo" class="campoTelaSemBorda">					 	
                      <option value="1" <?php if ($flgativo == "1")  { ?> selected <?php } ?> > ATIVO        </option>
                      <option value="0" <?php if ($flgativo == "0" ) { ?> selected <?php } ?> > INATIVO      </option>  													                      
                    </select>
                    <br />
                    <label for="flghomol"><? echo utf8ToHtml('Homologado:') ?></label>               
                    <select name="flghomol" id="flghomol" class="campoTelaSemBorda">					 	
                      <option value="0" <?php if ($flghomol == "0")  { ?> selected <?php } ?> > N&Atilde;O        </option>
                      <option value="1" <?php if ($flghomol == "1" ) { ?> selected <?php } ?> > SIM      </option>  													                      
                    </select>
					<br />
                    <label for="dtdhomol"><? echo utf8ToHtml('Data de homologação:') ?></label>
                    <input name="dtdhomol" id="dtdhomol" class="campoTelaSemBorda" readonly value="<?php echo $dtdhomol; ?>" />
                    <br />
                    <label for="cdopehom"><? echo utf8ToHtml('Operador homologação:') ?></label>
                    <input name="cdopehom" id="cdopehom" class="campoTelaSemBorda" readonly value="<?php if($cdopehom <> ''){ echo $cdopehom; } ?>" />
                    <br />
                    <label for="idretorn"><? echo utf8ToHtml('Forma envio arquivos:') ?></label>               
                    <select name="idretorn" id="idretorn" class="campoTelaSemBorda">					 	
                      <option value="1" <?php if ($idretorn == "1")  { ?> selected <?php } ?> > Internet Banking  </option>
                      <option value="2" <?php if ($idretorn == "2" ) { ?> selected <?php } ?> > FTP               </option>  													                      
                    </select>
					<br />
                    <label for="dtaltera"><? echo utf8ToHtml('Última alteração:') ?></label>
                    <input name="dtaltera" id="dtaltera" class="campoTelaSemBorda" readonly value="<?php echo $dtaltera; ?>" />
                    <br />
                    <label for="cdoperad"><? echo utf8ToHtml('Operador alteração:') ?></label>
                    <input name="cdoperad" id="cdoperad" class="campoTelaSemBorda" readonly value="<?php echo $cdoperad; ?>" />
                    <br />					
                    <label for="nrremret"><? echo utf8ToHtml('Última remessa:') ?></label>
                    <input name="nrremret" id="nrremret" class="campoTelaSemBorda" readonly value="<?php echo $nrremret; ?>" />
                    <br />					

	</fieldset>
	
	<div id="divemails">
		<fieldset>
			<legend><? echo utf8ToHtml('E-mails para retorno') ?></legend>
			<label for="dsemailsel">&nbsp;<? echo utf8ToHtml('E-mails do cooperado(CONTAS):') ?></label>
			<select id= "dsemailsel" name="dsemailsel" multiple>
						<?php
						foreach ($crapcem as $r) {
							$cddemail = getByTagName($r->tags, 'cddemail');
							$dsdemail = getByTagName($r->tags, 'dsdemail');
						?>
							<option value="<?php echo $cddemail; ?>">
								<?php echo $dsdemail; ?>
							</option>
						<?php
						}
						?>		
			</select>	
			<div id="divmatemail">
			<br />
			<div id="divBotoes">
				<a href="#" id="btAdicionar" class="botao" onClick="addEmailRetorno();">Adicionar&nbsp</a>
				<a href="#" id="btRemover" class="botao" onClick="removeEmailRetorno()">Remover&nbsp</a>
			</div>
			<br />		
			</div>
			<label for="dsemailsel">&nbsp;<? echo utf8ToHtml('E-mails para envio do retorno:') ?></label>
			<select id= "dsemailadd" name="dsemailadd" multiple>
				<?php
				foreach ($cptcem as $r) {
					$cddemail = getByTagName($r->tags, 'cddemail');
					$dsdemail = getByTagName($r->tags, 'dsdemail');
				?>
					<option value="<?php echo $cddemail; ?>">
						<?php echo $dsdemail; ?>
					</option>
				<?php
				}
				?>				
			</select>	
			
		</fieldset>
    </div>
		
	<div id="divBotoes">
		<a href="#" class="botao" onClick="acessaOpcaoAba();return false;" >Voltar&nbsp </a>			
		<?php if($cddopcao == 'I'){ ?>
		<a href="#" class="botao" onClick="fnConfirmaInclusao();" >Incluir&nbsp </a>
		<?php }?>
		<?php if($cddopcao == 'A'){ ?>
		<a href="#" class="botao" onClick="fnConfirmaAlteracao();" >Alterar&nbsp </a>
		<?php }?>
		
	</div>
	
	
</form>

<script type="text/javascript">
controlaLayout('frmConsulta','<?php echo $cddopcao; ?>');

$("#divConteudoOpcao").css("display","none");
$("#divOpcaoIncluiAltera").css("display","none");

$("#divOpcaoConsulta").css("display","block");

blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
