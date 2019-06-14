<? 
/*!
 * FONTE        : carrega_tela_incluir_grupo_economico.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : 13/07/2017
 * OBJETIVO     : Rotina para carregar a tela de inclusao do Gupo Economico
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> ''){
		exibirErro('error',$msgError,'Alerta - Aimaro','',true);
	}
	
	require_once("grupo_economico_inclusao.php");
?>
<script>
controlaLayoutInclusaoGrupoEconomico();
$('#divUsoGenerico').css('z-index','100');
$('#divUsoGenerico').css('width','480px');
</script>