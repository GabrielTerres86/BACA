<?
/*!
 * FONTE        : form_resp_assinatura.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 11/01/2018
 * OBJETIVO     : Tela de exibição dos responsaveis pela assinatura para escolha
 * --------------
 * ALTERAÇÕES   :
 */		

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');
isPostMethod();		

// Guardo os parâmetos do POST em variáveis	
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA", "BUSCA_RESP_ASSINATURA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);		
//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	exit();
}

?>
<span><? echo utf8ToHtml('Selecione o sócio que está realizando o resgate.') ?></span>
<div class="divRegistros" id="divResponsaveis">	
	<table class="tituloRegistros" id="tabelaResponsaveis">
		<thead>
			<tr>
				<th></th>
				<th>Nome</th>
			</tr>
		</thead>
		<tbody>
			<?
			if(strtoupper($xmlObj->roottag->tags[0]->name == 'RESPONSAVEIS')){	
				foreach($xmlObj->roottag->tags[0]->tags as $responsavel){
					?>
					<tr>
						<td id="nrcpfcgc" >
							<input type="radio" name="nrcpfcgc" value="<? echo $responsavel->tags[1]->cdata; ?>" />
						</td>
						<td id="nmprimtl" >
							<? echo $responsavel->tags[0]->cdata; ?>
						</td>
					</tr>
					<?
				}		
			}
			?>
		</tbody>
	</table>
</div>
<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina(divRotina); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguirAutorizacao" onclick="selecionarResponsavel(); return false;" >Prosseguir</a>
</div>