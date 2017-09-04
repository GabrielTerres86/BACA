/*
  Programa: formatadadosie.js

Alteracoes: 15/12/2008 - Alteracoes para unificacao dos bancos de dados (Evandro).

            31/08/2009 - Permitir alterar o tamanho da janela principal do caixa
                         (Evandro).
                         
            17/03/2010 - Adicionada a rotina 61 (Evandro).
			
			01/06/2011 - Adicionada a rotina IP - Impressora (Adriano).
			
			27/07/2011 - Adicionado as rotinas 66 e 86 (Guilherme).
            
            03/11/2011 - Adicionado rotina 22 (Elton).
			
			17/10/2012 - Adicionado função para formatar CEP (Daniel).
			
			04/09/2017 - Removido rotinas 84, 85 pois nao serao mais usadas (Tiago/Elton #679866).
*/

// < ! --
//Bloco de código para esconder e mostra form
var Ver4 = parseInt(navigator.appVersion) >= 4
var IE4 = ((navigator.userAgent.indexOf("MSIE") != -1) && Ver4)
var block = "formulario";

function esconde() {        document.forms.style.visibility = "hidden" }
function mostra() { document.forms.style.visibility = "visible" }
//Bloco de código para esconder e mostra form


// Código para o teclado 
function tecladown (digito){
        if (digito == ''){
                document.forms.senha.value = '';
                return;        
        }
        var pass = document.forms.senha.value;
        if (pass.length >= 8){
                return;
        }
        document.forms.senha.value = document.forms.senha.value + digito;
}
function teclaclick(tecla){
        return false;
}
function teclaup(tecla){
        tecladown(tecla);
}
// --


// -- Contador para objeto TextArea.
function limita(campo){
        var tamanho = document.forms[campo].value.length;
        var tex=document.forms[campo].value;
        if (tamanho>=1199) {
                document.forms[campo].value=tex.substring(0,1199); 
        }
        return true;
}

function contacampo(campo, tamtxt) {
document.forms[tamtxt].value =  1200-document.forms[campo].value.length;
}
// --

function SetHelp(txt) { help.innerText = txt ; }

function FormataCgc(campo,tammax,teclapres) {
        var tecla = teclapres.keyCode;
        vr = document.forms[campo].value;
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( ",", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        tam = vr.length;

        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
                
        if ( tecla == 8 || tecla >= 48 && tecla <= 57 || tecla >= 96 && tecla <= 105 ){
                if ( tam <= 2 ){ 
                         document.forms[campo].value = vr ; }
                 if ( (tam > 2) && (tam <= 6) ){
                         document.forms[campo].value = vr.substr( 0, tam - 2 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 7) && (tam <= 9) ){
                         document.forms[campo].value = vr.substr( 0, tam - 6 ) + '/' + vr.substr( tam - 6, 4 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 10) && (tam <= 12) ){
                         document.forms[campo].value = vr.substr( 0, tam - 9 ) + '.' + vr.substr( tam - 9, 3 ) + '/' + vr.substr( tam - 6, 4 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 13) && (tam <= 14) ){
                         document.forms[campo].value = vr.substr( 0, tam - 12 ) + '.' + vr.substr( tam - 12, 3 ) + '.' + vr.substr( tam - 9, 3 ) + '/' + vr.substr( tam - 6, 4 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 15) && (tam <= 17) ){
                         document.forms[campo].value = vr.substr( 0, tam - 14 ) + '.' + vr.substr( tam - 14, 3 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ;}
        }                
}

function VerificaJava()
         {
        if (navigator.javaEnabled())
                document.forms.javas.value="sim"
        }

function FormataCpf(campo,tammax,teclapres) {
        var tecla = teclapres.keyCode;
        vr = document.forms[campo].value;
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( ",", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        tam = vr.length;

        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
                
        if ( tecla == 8 || tecla >= 48 && tecla <= 57 || tecla >= 96 && tecla <= 105 ){
                if ( tam <= 2 ){ 
                         document.forms[campo].value = vr ; }
                 if ( (tam > 2) && (tam <= 5) ){
                         document.forms[campo].value = vr.substr( 0, tam - 2 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 6) && (tam <= 8) ){
                         document.forms[campo].value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 9) && (tam <= 11) ){
                         document.forms[campo].value = vr.substr( 0, tam - 8 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 12) && (tam <= 14) ){
                         document.forms[campo].value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 15) && (tam <= 17) ){
                         document.forms[campo].value = vr.substr( 0, tam - 14 ) + '.' + vr.substr( tam - 14, 3 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ;}
        }                
}

function Apaga(){
        if (document.forms.elements.length != 0)
                for (i = 0; i < document.forms.elements.length; i++)
                {
                        if( document.forms[i].type != "hidden" )
                                document.forms[i].value="";
                }
}


var da = (document.all) ? 1 : 0;
var pr = (window.print) ? 1 : 0;
var mac = (navigator.userAgent.indexOf("Mac") != -1); 

function printPage()
{
  if (pr) // NS4, IE5
    window.print()
  else if (da && !mac) // IE4 (Windows)
    vbPrintPage()
  else // other browsers
    alert("Desculpe seu browser não suporta esta função. Por favor utilize a barra de trabalho para imprimir a página.");
  return false;
}

if (da && !pr && !mac) with (document) {
  writeln('<OBJECT ID="WB" WIDTH="0" HEIGHT="0" CLASSID="clsid:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>');
  writeln('<' + 'SCRIPT LANGUAGE="VBScript">');
  writeln('Sub window_onunload');
  writeln('  On Error Resume Next');
  writeln('  Set WB = nothing');
  writeln('End Sub');
  writeln('Sub vbPrintPage');
  writeln('  OLECMDID_PRINT = 6');
  writeln('  OLECMDEXECOPT_DONTPROMPTUSER = 2');
  writeln('  OLECMDEXECOPT_PROMPTUSER = 1');
  writeln('  On Error Resume Next');
  writeln('  WB.ExecWB OLECMDID_PRINT, OLECMDEXECOPT_DONTPROMPTUSER');
  writeln('End Sub');
  writeln('<' + '/SCRIPT>');
}
/*vr = document.forms[campo].value;*/

function FormataDado(campo,tammax,pos,teclapres){
        var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( "-", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( "/", "" );
        tam = vr.length ;

   /*aqui valida inteiro*/
   if ( ( tecla < 48 || tecla > 57 && tecla < 96 || tecla > 105) && tecla != 8 && tecla != 9){
      event.returnValue = false;
      return;
   }

   /*formato de conta bancaria*/
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){ tam = tam - 1 ; }
                        
        if ( tecla == 8 || tecla == 88 || tecla >= 48 && tecla <= 57 || tecla >= 96 && tecla <= 105 ){
                if ( tam <= 2 ){
                         campo.value = vr ;}
                if ( tam > pos && tam <= tammax ){
                        campo.value = vr.substr( 0, tam - pos ) + '-' + vr.substr( tam - pos, tam );}
        } 
}

function alteraFoco(){
   alert(campo);
        if(campo == "98") {
                return;
        }
        if (document.forms[0].elements[campo])
                document.forms[0].elements[campo].focus();
}
/******************/

///função para iniciar a tela com o campo focado///
function main(campofoco) { 
   document.forms[0].elements[campofoco].focus(); 
}

///função para mudar o foco de um campo para outro///
function mudaFoco(){

   var i_campo = 0;

   if (document.forms[0].vh_foco.value == "")
      document.forms[0].vh_foco.value = 0;

   i_campo = document.forms[0].vh_foco.value;

   while ((document.forms[0].elements[i_campo].disabled ||
           document.forms[0].elements[i_campo].type == "hidden")
       && i_campo < document.forms[0].length) {
      i_campo++;
   }

   if (document.forms[0].elements[i_campo].disabled ||
       document.forms[0].elements[i_campo].type == "hidden") {
      i_campo = 0;
      while ((document.forms[0].elements[i_campo].disabled ||
              document.forms[0].elements[i_campo].type == "Hidden")
          && i_campo < document.forms[0].vh_foco.value) {
         i_campo++;
      }
   }

   if (document.forms[0].elements[i_campo].disabled == false &&
       document.forms[0].elements[i_campo].type != "hidden")
      document.forms[0].elements[i_campo].focus();
}

///função para validar campos com valores inteiros///
function validaInteiro(teclapres){
   var tecla = teclapres.keyCode;   
   if ( ( (tecla < 37 || tecla > 40) && (tecla < 48 || tecla > 57) && (tecla < 96 || tecla > 105)) && tecla != 8 && tecla != 9 && tecla!= 46){
         event.returnValue = false;
         return;
   }
}

///função para formatar campos com valores decimais///
function FormataValor(campo,tammax,teclapres) {
   
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( ",", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;

        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
                
        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 2 ){ 
                         campo.value = vr ; }
                 if ( (tam > 2) && (tam <= 5) ){
                         campo.value = vr.substr( 0, tam - 2 ) + ',' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 6) && (tam <= 8) ){
                         campo.value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 9) && (tam <= 11) ){
                         campo.value = vr.substr( 0, tam - 8 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 12) && (tam <= 14) ){
                         campo.value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 15) && (tam <= 17) ){
                         campo.value = vr.substr( 0, tam - 14 ) + '.' + vr.substr( tam - 14, 3 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ;}
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}

}

///função para formatar campos cmc7///
function FormataCmc7(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }
   /*alert(campo.value)*/
        if (tecla == 8 ){        tam = tam - 1 ; }
                
        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam = 1 ){ 
                         campo.value = vr.substr( 0, tam - 2 ) + vr.substr( 0, tam ) + ':';
      }
      if ( tam >= 2) {
         campo.value = vr.substr( 0, tam - 2 ) + vr.substr( 0, tam ) + ':';
      }
/*                 if ( (tam > 1) && (tam <= 12) ){
                         campo.value = vr.substr( 0, tam - 1 ) + ':' + vr.substr( tam - 5, tam ) ; }
           if ( (tam >= 11) && (tam <= 15) ){
                         campo.value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 5 ) + '.' + vr.substr( tam - 5, tam ) ; }*/
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}  

///função para formatar campos de títulos///
function FormataTitulo(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 5 ){ 
                         campo.value = vr ; }
                 if ( (tam > 5) && (tam <= 10) ){
                         campo.value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, tam ) ; }
           if ( (tam >= 11) && (tam <= 15) ){
                         campo.value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 5 ) + '.' + vr.substr( tam - 5, tam ) ; }
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}  

///função para formatar campos de títulos///
function FormataTitulos(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
                
        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 5 ){ 
                         campo.value = vr ; }
                 if ( (tam > 5) && (tam <= 10) ){
                         campo.value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, tam ) ; }
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}  

///função para formatar campos de títulos///
function FormataTitulof(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
                
        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 6 ){ 
                         campo.value = vr ; }
                 if ( (tam > 6) && (tam <= 9) ){
                         campo.value = vr.substr( 0, tam - 6 ) + '.' + vr.substr( tam - 6, tam ) ; }
                 if ( (tam >= 10) && (tam <= 12) ){
                         campo.value = vr.substr( 0, tam - 9 ) + '.' + vr.substr( tam - 9, 3 ) + '.' + vr.substr( tam - 6, tam ) ; }
                 if ( (tam >= 13) && (tam <= 15) ){
                         campo.value = vr.substr( 0, tam - 12 ) + '.' + vr.substr( tam - 12, 3 ) + '.' + vr.substr( tam - 9, 3 ) + '.' + vr.substr( tam - 6, tam ) ; }
                 if ( (tam >= 16) && (tam <= 17) ){
                         campo.value = vr.substr( 0, tam - 15 ) + '.' + vr.substr( tam - 15, 2 ) + '.' + vr.substr( tam - 12, 3 ) + '.' + vr.substr( tam - 9, 3 ) + '.' + vr.substr( tam - 6, tam ) ;}
   }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}  

///função para formatar campos de faturas///
function FormataFatura(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
                
        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 1 ){ 
                         campo.value = vr ; }
                 if ( (tam > 1) && (tam <= 7) ){
                         campo.value = vr.substr( 0, tam - 1 ) + '.' + vr.substr( tam - 1, tam ) ; }
                 if ( (tam >= 8) && (tam <= 12) ){
                         campo.value = vr.substr( 0, tam - 7 ) + '.' + vr.substr( tam - 7, 6 ) + '.' + vr.substr( tam - 1, tam ) ; }
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}  

///função para formatar campos de conta///
function FormataConta(campo,tammax,teclapres) {
   
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;

        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
                
        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105))  {
                if ( tam <= 1 ){ 
                         campo.value = vr ; }
                 if ( (tam > 1) && (tam <= 4) ){
                         campo.value = vr.substr( 0, tam - 1 ) + '.' + vr.substr( tam - 1, tam ) ; }
                 if ( (tam >= 5) && (tam <= 9) ){
                         campo.value = vr.substr( 0, tam - 4 ) + '.' + vr.substr( tam - 4, 3 ) + '.' + vr.substr( tam - 1, tam ) ; }
                     
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}

///função para formatar a data///
function FormataData(Campo,teclapres) {
        var tecla = teclapres.keyCode;

   if ( ( tecla < 48 || tecla > 57 && tecla < 96 || tecla > 105) && tecla != 8 && tecla != 9 && tecla!= 16){
         event.returnValue = false;
         return;
   }

        vr = Campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        tam = vr.length + 1;

        if ( tecla != 9 && tecla != 8 ){
                if ( tam > 2 && tam < 5 )
                        Campo.value = vr.substr( 0, tam - 2  ) + '/' + vr.substr( tam - 2, tam );
                if ( tam >= 5 && tam <= 10 )
                        Campo.value = vr.substr( 0, 2 ) + '/' + vr.substr( 2, 2 ) + '/' + vr.substr( 4, 4 ); }
}

///função para mudar o foco do campo atual para o campo de rotina do menu///
function change_page(e) {
    if(e.keyCode == 27)
       top.frames[0].document.forms[0].v_rotina.focus();  
    return true;
   }

///função para chamar o programa quando executado pelo campo de rotina///
function change_location() {
    if(document.forms[0].v_rotina.value == 2) {
        top.frames[1].window.location.href="crap002.html" ;
    }
    else if(document.forms[0].v_rotina.value == 5) {
        top.frames[1].window.location.href="crap005.html" ;
    }
    else if(document.forms[0].v_rotina.value == 6) {
        top.frames[1].window.location.href='crap006.w' ; 
    }
    else if(document.forms[0].v_rotina.value == 7) {
        top.frames[1].window.location.href="crap007.html" ;
    }
    else if(document.forms[0].v_rotina.value == 8) {
        top.frames[1].window.location.href="crap008.html" ;
    }
    else if(document.forms[0].v_rotina.value == 9) {
        top.frames[1].window.location.href="crap009.html" ;
    }
    else if(document.forms[0].v_rotina.value == 10) {
        top.frames[1].window.location.href='login.w?v_prog=crap010.w' ;
    }
    else if(document.forms[0].v_rotina.value == 11) {
        top.frames[1].window.location.href="crap011.html" ;
    }
    else if(document.forms[0].v_rotina.value == 12) {
        top.frames[1].window.location.href="crap012.html" ;
    }
    else if(document.forms[0].v_rotina.value == 13) {
        top.frames[1].window.location.href="crap013.html" ;
    }
    else if(document.forms[0].v_rotina.value == 14) {
        top.frames[1].window.location.href="crap014.html" ;
    }
    else if(document.forms[0].v_rotina.value == 15) {
         top.frames[1].window.location.href='login.w?v_prog=crap015.w' ;
    }
    else if(document.forms[0].v_rotina.value == 16) {
        top.frames[1].window.location.href="crap016.html" ;
    }
    else if(document.forms[0].v_rotina.value == 17) {
       top.frames[1].window.location.href='login.w?v_prog=crap017.w' ;    
    }
    else if(document.forms[0].v_rotina.value == 18) {
        top.frames[1].window.location.href="crap018.html" ;
    }
    else if(document.forms[0].v_rotina.value == 19) {
        top.frames[1].window.location.href="crap019.html" ;
    }
    else if(document.forms[0].v_rotina.value == 20) {
        top.frames[1].window.location.href="crap020.html" ;
    }
    else if(document.forms[0].v_rotina.value == 21) {
        top.frames[1].window.location.href='login.w?v_prog=crap021.w' ;
    }
    else if(document.forms[0].v_rotina.value == 22) {
        top.frames[1].window.location.href="crap022.html" ;
    }
    else if(document.forms[0].v_rotina.value == 31) {
        top.frames[1].window.location.href="crap031.html" ;
    }
    else if(document.forms[0].v_rotina.value == 32) {
        top.frames[1].window.location.href="crap032.html" ;
    }
    else if(document.forms[0].v_rotina.value == 33) {
        top.frames[1].window.location.href="crap033.html" ;
    }
    else if(document.forms[0].v_rotina.value == 34) {
        top.frames[1].window.location.href="crap034.html" ;
    }
    else if(document.forms[0].v_rotina.value == 35) {
        top.frames[1].window.location.href="crap035.html" ;
    }
     else if(document.forms[0].v_rotina.value == 36) {
        top.frames[1].window.location.href="crap036.html" ;
    }
     else if(document.forms[0].v_rotina.value == 37) {
        top.frames[1].window.location.href="crap037.html" ;
    }
    else if(document.forms[0].v_rotina.value == 40) {
        top.frames[1].window.location.href="crap040.html" ;
    }
    else if(document.forms[0].v_rotina.value == 51) {
        top.frames[1].window.location.href="crap051.html" ;
    }
    else if(document.forms[0].v_rotina.value == 52) {
        top.frames[1].window.location.href="crap052.html" ;
    }
    else if(document.forms[0].v_rotina.value == 53) {
        top.frames[1].window.location.href="crap053.html" ;
    }
    else if(document.forms[0].v_rotina.value == 54) {
        top.frames[1].window.location.href="crap054.html" ;
    }
    else if(document.forms[0].v_rotina.value == 55) {
        top.frames[1].window.location.href="crap055.html" ;
    }
    else if(document.forms[0].v_rotina.value == 56) {
        top.frames[1].window.location.href="crap056.html" ;
    }
    else if(document.forms[0].v_rotina.value == 57) {
        top.frames[1].window.location.href="crap057.html" ;
    }
    else if(document.forms[0].v_rotina.value == 58) {
        top.frames[1].window.location.href="crap058.html" ;
    }
    else if(document.forms[0].v_rotina.value == 61) {
        top.frames[1].window.location.href="crap061.html" ;
    }
    else if(document.forms[0].v_rotina.value == 66) {
        top.frames[1].window.location.href="crap066.html" ;
    }
    else if(document.forms[0].v_rotina.value == 86) {
        top.frames[1].window.location.href='login.w?v_prog=crap086.html'; 
    }	
    else if(document.forms[0].v_rotina.value == 71) {
        top.frames[1].window.location.href='login.w?v_prog=crap071.html'; 
    }
    else if(document.forms[0].v_rotina.value == 72) {
        top.frames[1].window.location.href='login.w?v_prog=crap072.w';
    }
    else if(document.forms[0].v_rotina.value == 73) {
        top.frames[1].window.location.href='login.w?v_prog=crap073.w';
    }
    else if(document.forms[0].v_rotina.value == 74) {
        top.frames[1].window.location.href='login.w?v_prog=crap074.w';
    }
    else if(document.forms[0].v_rotina.value == 75) {
        top.frames[1].window.location.href='login.w?v_prog=crap075.w';
    }
    else if(document.forms[0].v_rotina.value == 76) {
        top.frames[1].window.location.href='login.w?v_prog=crap076.w';
    }
    else if(document.forms[0].v_rotina.value == 77) {
        top.frames[1].window.location.href='login.w?v_prog=crap077.w';
    }
    else if(document.forms[0].v_rotina.value == 78) {
        top.frames[1].window.location.href='login.w?v_prog=crap078.w';
    }
    else if(document.forms[0].v_rotina.value == 79) {
        top.frames[1].window.location.href='login.w?v_prog=crap079.w';

    }
    else if(document.forms[0].v_rotina.value == 80) {
        top.frames[1].window.location.href="crap080.html";
    }
    else if(document.forms[0].v_rotina.value == 81) {
         top.frames[1].window.location.href='login.w?v_prog=crap081.w' ;
    }
    else if(document.forms[0].v_rotina.value == 82) {
        top.frames[1].window.location.href="crap082.html";
    }
    else if(document.forms[0].v_rotina.value == 83) {
         top.frames[1].window.location.href='login.w?v_prog=crap083.w' ;   
    }
    else if(document.forms[0].v_rotina.value == 'at' || document.forms[0].v_rotina.value == 'AT') {
        top.frames[1].window.location.href='login.w?v_prog=autentmenu.w';    
    }
    else if(document.forms[0].v_rotina.value == 'ip' || document.forms[0].v_rotina.value == 'IP') {
        top.frames[1].window.location.href='impressora.w';    
    }
	
    else if(document.forms[0].v_rotina.value == 'aa' || document.forms[0].v_rotina.value == 'AA') {
        top.frames[1].window.location.href='logingerente.w?v_prog=autantmenu.w';
    }
    else if(document.forms[0].v_rotina.value == 'bli' || document.forms[0].v_rotina.value == 'BLI') {
        window.open('blini.p','werro','width=500,height=240,scrollbars=auto,alwaysRaised=true,left=0,top=0') ;
    }
    else if(document.forms[0].v_rotina.value == 'bls' || document.forms[0].v_rotina.value == 'BLS') {
        window.open('blsal.p','werro','width=500,height=240,scrollbars=auto,alwaysRaised=true,left=0,top=0') ;
    }
    else if(document.forms[0].v_rotina.value == 'cl' || document.forms[0].v_rotina.value == 'CL') {
        window.open('calc.w','werro','height=190,width=270,scrollbars=auto,alwaysRaised=true,left=0,top=0') ;
    }
    else{
        top.frames[1].window.location.href="crap002.html" ;
    }

/*    else{
       alert("Rotina não Existe!");
       top.frames[1].window.location.href="crap002.html" ;
    }*/
}

///função para abrir outro programa passando parâmetros///
function redireciona(campo) {
   if (campo.name == "crap003" || campo.name == "crap004") {
      window.location = campo.name + '.html?v_cta=' + document.forms[0].v_conta.value +
         '&v_nom=' + document.forms[0].v_nome.value + '&v_nomconj=' + document.forms[0].v_nomconj.value;    
   }
   else if (campo.name == "crap004a") {
      window.location = campo.name + '.html?v_row=' + document.forms[0].v_rowid.value;
      }
   else if (campo.name == "crap002") {
      window.location = campo.name + '.html?v_row=' + document.forms[0].v_rowid.value;
      }
}

function redir_login(prog){
   window.location = 'login.w?v_prog=' + prog;
}

function redir_zoom(){
   window.location = 'crap002c.html?v_nome=' + document.forms[0].v_nome.value;
}

function preenchimento(evento,foco,campo,tamanho,objeto){

   if (campo.value.length == tamanho) {
      // Menu
      if (objeto == "menu") {
         change_location();
      }
      else {
         // Campo
         if (objeto == "submit") {
             document.forms[0].submit();
             for(var i=0;i<document.forms[0].length;i++){
                document.forms[0].elements[i].disabled=true;
             }
         }
         if (objeto == "foco") {
            for(var i=0;i<document.forms[0].length;i++){
               if (document.forms[0].elements[i].name == campo.name) {
                  document.forms[0].elements[i+1].focus();
               } 
            }
         }
         else {
            // Botão
            for(var i=0;i<document.forms[0].length;i++){
               if (document.forms[0].elements[i].name == objeto) {
                  document.forms[0].elements[i].click();
               }
            }
         }
      }
   }
   else {
      if (evento.keyCode == 13) {
         if (foco == 0) {
            document.forms[0].submit();
         }
         else {
            document.forms[0].elements[foco].focus();
         }
      }
   }
}

function onTop() {
   setTimeout("self.focus()",250);
}

function onKey(e) {
    if(e.keyCode == 13){
       document.forms[0].submit(); 
   }
   else{
      if(e.keyCode == 27) {
         window.close();
      }
   }
}

function callCalc(e, obj) {
        if (e.keyCode == 120) {
                window.open("calc.htm?elem=" + obj.name, "wincalc", "resizable=no, height=190, width=270, left=0, top=0");
        }
}

function callBLini(e) {
        if (e.keyCode == 119) {
      window.open('blini.p','wbl','width=500,height=240,scrollbars=auto,resizable=no,alwaysRaised=true, left=0, top=0');
   }
}

function callBLsal(e) {
        if (e.keyCode == 118) {
      window.open('blsal.p','wbl','width=500,height=240,scrollbars=auto,resizable=no,alwaysRaised=true, left=0, top=0');
   }
}

function log() {
   var Cookies = document.cookie;
   var URL = document.URL;
   var COOP;
   
   // verifica o parametro da cooperativa existe
   if(URL.match("aux_cdcooper")==null){
      return false;
   }
   
   COOP = URL.substring(URL.indexOf("aux_cdcooper=") + 13,URL.length);
   
   // separa o parametro dos demais, caso existam
   if(COOP.match("&")!=null){
      COOP = COOP.substring(0,COOP.indexOf("&"));   
   }
   
   if (Cookies.indexOf("User_cx") != -1 && Cookies.indexOf("User_pac") != -1) {
      window.open("crap001.html","wsis","width=640,height=420,scrollbars=auto,alwaysRaised=true,resizable=yes,left=0,top=0");
   }
   else 
      window.open("configura.w?aux_cdcooper=" + COOP,"wconfig","width=640,height=420,scrollbars=auto,alwaysRaised=true,resizable=yes,left=0,top=0");
          
}
function fecha() {
   alert("fechar");
  opener.close(); 
}

function click() {
//   if (event.button==2) {
//      alert('Click Esquerdo Desabilitado')
//   }
}
document.onmousedown=click

//-->

// Vander - Funcao que desabilita botões de submits e limpeza de campos

function desabok() 
{
   if (window.action.ok.value != "Ok")
   {
      window.action.ok.value = "Ok";
      for (i = 0; i < action.length; i++) 
      {
         var tempobj = action.elements[i];
         if (tempobj.type.toLowerCase() == "submit" || tempobj.type.toLowerCase() == "reset")
         tempobj.disabled = true;
      }
      window.action.submit();
   }
}


function desabilita(botao) 
{        
   document.all[botao].style.display='none';
}


// Vander - Funcao que restringe o escape na autenticação

function onKeyAutent(e, v) {
    document.action.aut.value = v;
    if(e.keyCode == 13){
       document.action.aut.value = "Ok";
       document.forms[0].submit(); 
   }
   else{
      if(e.keyCode == 27 && document.action.aut.value == "Ok") {
           window.close();
      }
      else
      {
      alert("Você deve realizar ao menos uma autenticação.");
      }
   }
}

function CriaArray(n) {
  this.length = n;
  for (i = 1; i <= n; i++) {
    this[i]="";
  }
}

function Difdocto(v,p) {
   if (v != p) 
      alert("Numero do documento invalido");
   else
      return true;
}       


// valida os caracteres digitados na descricao
function validaDescricao(campo,valor){

   if((event.keyCode==9)||    // TAB
      (event.keyCode==16)){   // BACK-TAB
       return true;
   } 
   
   // varre o campo em busca de caracteres inválidos e remove-os
   for(var i=0;i< document.all[campo].value.length;i++){
      if((document.all[campo].value.substring(i,i+1)=='@') ||
                   (document.all[campo].value.substring(i,i+1)=='#') ||
                 (document.all[campo].value.substring(i,i+1)=='$') ||
                 (document.all[campo].value.substring(i,i+1)=='%') ||
                 (document.all[campo].value.substring(i,i+1)=='¨') ||
                 (document.all[campo].value.substring(i,i+1)=='=') ||                 
                 (document.all[campo].value.substring(i,i+1)=='&') ||
                 (document.all[campo].value.substring(i,i+1)=='º') ||
                 (document.all[campo].value.substring(i,i+1)=='ª') ||
                 (document.all[campo].value.substring(i,i+1)=='§') ||
                 (document.all[campo].value.substring(i,i+1)=='°') ||
                 (document.all[campo].value.substring(i,i+1)=='¬') ||
                 (document.all[campo].value.substring(i,i+1)=='¢') ||
                 (document.all[campo].value.substring(i,i+1)=='£') ||
                 (document.all[campo].value.substring(i,i+1)=='³') ||
                 (document.all[campo].value.substring(i,i+1)=='²') ||
                 (document.all[campo].value.substring(i,i+1)=='¹') ||
                 (document.all[campo].value.substring(i,i+1)=='°') ||
                 (document.all[campo].value.substring(i,i+1)=='?') ||
                 (document.all[campo].value.substring(i,i+1)=='"') ||
                 (document.all[campo].value.substring(i,i+1)=="'"))    
          document.all[campo].value = document.all[campo].value.substring(0,i);
   }
}

///função para formatar cep///
function FormataCep(Campo,teclapres) {
   
   
   var tecla = teclapres.keyCode;
   if ( ( tecla < 48 || tecla > 57 && tecla < 96 || tecla > 105) && tecla != 8 && tecla != 9 && tecla!= 16){
         event.returnValue = false;
         return;
   }

        vr = Campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        tam = vr.length + 1;

        if ( tecla != 9 && tecla != 8 ){
                if ( tam > 3 && tam < 8)
                        Campo.value = vr.substr( 0, tam - 3  ) + '-' + vr.substr( tam - 3, tam );
						
				if ( tam = 8 )
				Campo.value = vr.substr( 0, 5 ) + '-' + vr.substr( 5, 3 );
                 }              
				 
}
