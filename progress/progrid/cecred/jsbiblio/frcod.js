// Biliotecas de Fun��es em JavaScript

// Funcao: VE(Valida Elemento)
// Objetivo: verificar se um elemento(componente) est� no formato adequado (caracter, inteiro, data, decimal)
// Parametros de entrada:
//    tc = tipo do componente. "ca":caracter, "da":data, "de":decimal, "in":inteiro
//    nc = nome do componente.
//    lc = label do componente.
//    pn = componente pode ser nulo? "sim"/"nao"
//    mi = valor m�nimo do componente
//    ma = valor m�ximo do componente
// Parametros de sa�da:
//    msg = Mensagem de Erro da valida��o

function VE(tc,nc,lc,pn,mi,ma)
{  
  var msg = "";
  var p = "xx";
  var z = 1;
  var x = 0; 
  var cv = 0;
  var dia = 0;
  var mes = 0;
  var ano = 0;
  var aux = "";
  var aux2 = nc.value;
  pn.toLowerCase();
  tc.toLowerCase();

  if (tc == "de") {
    for (var x = 0; x < aux2.length; x++) {
      if (aux2.substring(x,x+1) != " ")
        aux = aux + aux2.substring(x,x+1);
    } 
    nc.value = aux;
  }
  if (tc == "ca") {
    if (pn == "sim")
      {}
    else {
      if (nc.value == "")
        msg = lc + " n�o pode ser nulo.";
    }
    if (nc.value.substring(0,1) == " ")
      msg = msg + lc + " n�o pode come�ar com branco.";
  }
  else
  if (tc == "in") {
    p = "0123456789";
    if (pn == "sim") {  
      if (nc.value == "")
        nc.value = "0";
      else {
        for (var x = 0; x < nc.value.length; x++)  {
          if (p.indexOf(nc.value.substring(x,x+1)) == -1)
            z = 0;
        } 
        if (z == 0)
          msg = msg + lc + " possui caracteres que n�o s�o validos.";  
        if (msg == "") {
          if (nc.value < mi)
            msg = msg + lc + " deve ser maior que " + mi.toString() + ".";
          if (nc.value > ma)
            msg = msg + lc + " deve ser menor que " + ma.toString() + ".";
        }
      }
    }
    else {
      if (nc.value == "")
        msg = msg + lc + " n�o pode ser nulo.";
        for (var x = 0; x < nc.value.length; x++) {
        if (p.indexOf(nc.value.substring(x,x+1)) == -1)
                      z = 0;
               } 
               if (z == 0)
                  msg = msg + lc + " possui caracteres que n�o s�o validos.";  
               if (msg == "") {
                  if (nc.value < mi)
                     msg = msg + lc + " deve ser maior que " + mi.toString() + ".";
                  if (nc.value > ma)
                     msg = msg + lc + " deve ser menor que " + ma.toString() + ".";
               }
         }
      }
      else
      if (tc == "de") {
         p = ",0123456789";
         if (pn == "sim") {  
            if (nc.value == "")
               nc.value = "0";
            else {
                 for (var x = 0; x < nc.value.length; x++) {
                     if (p.indexOf(nc.value.substring(x,x+1)) == -1 & nc.value.substring(x,x+1) != ".") {
                        z = 0;
                     }
                     if (nc.value.substring(x,x+1) == ".")
                        cv = cv + 1;
                 } 
                 if (cv > 2)
                    z = 0;
                 if (z == 0) {
                    msg = msg + lc + " possui caracteres que n�o s�o validos.";  
                 }
                 if (msg == "") {
                    if (nc.value < mi) 
                       msg = msg + lc + " deve ser maior que " + mi.toString() + ".";  
                    if (nc.value > ma)
                       msg = msg + lc + " deve ser menor que " + ma.toString() + ".";
                 }
            }
         }
         else {
              if (nc.value == "")
                 msg = msg + lc + " n�o pode ser nulo.";
              for (var x = 0; x < nc.value.length; x++) {
                  if (p.indexOf(nc.value.substring(x,x+1)) == -1  & nc.value.substring(x,x+1) != ".")
                     z = 0;
                  if (nc.value.substring(x,x+1) == ".")
                     cv = cv + 1;
              } 
              if (cv > 1)
                 z = 0;
              if (z == 0) {
                 msg = msg + lc + " possui caracteres que n�o s�o validos.";  
              }
              if (msg == "") {
                 if (nc.value < mi)
                    msg = msg + lc + " deve ser maior que " + mi.toString() + ".";
                 if (nc.value > ma)
                    msg = msg + lc + " deve ser menor que " + ma.toString() + ".";
              }
         }
      }
      else
      if (tc == "da") {
         p = "0123456789/";
         if (pn == "sim") {  
            if (nc.value == "")
               {}
            else {
                 for (var x = 0; x < nc.value.length; x++) {
                     if (p.indexOf(nc.value.substring(x,x+1)) == -1)
                        z = 0;
                     if (nc.value.substring(x,x+1) == "/")
                        cv = cv + 1;
                 } 
                 if (cv != 2)
                    z = 0;
                 if (z == 0)
                    msg = msg + lc + " possui caracteres que n�o s�o validos.";  
                 if (msg == "") {
                    p1 = nc.value.indexOf("/") ;
                    p2 = nc.value.lastIndexOf("/") ;
                    if ((p2 == (p1 + 1)) || (nc.value.substring(0,p1).length == 0) || (nc.value.substring(p1+1,p2).length == 0) || (nc.value.substring(p2+1,nc.value.length).length == 0))
                       msg = msg + lc + " possui os separadores fora de lugar.";
                    else {
                          dia = parseInt(nc.value.substring(0,p1),10);
                          mes = parseInt(nc.value.substring(p1+1,p2),10);
                          ano = parseInt(nc.value.substring(p2+1,nc.value.length),10);
                          if ((mes < 1) || (mes > 12))
                             msg = msg + lc + " deve possuir o m�s entre 1 e 12.";
                          if ((mes==1) || (mes==3) || (mes==5) || (mes==7) || (mes==8) || (mes==10) || (mes==12))  {
                             if ((dia < 1) || (dia > 31))
                                msg = msg + lc + " deve possuir o dia entre 1 e 31.";
                             }
                             else {        
                                  if (mes!=2) {
                                     if ((dia < 1) || (dia > 30))
                                        msg = msg + lc + " deve possuir o dia entre 1 e 30.";
                                  }
                                  else {
                                       if (mes==2) {
                                          if ((ano % 4) == 0) { 
                                             if ((dia < 1) || (dia > 29))
                                                msg = msg + lc + " deve possuir o dia entre 1 e 29.";
                                          }
                                          else  {
                                                if ((dia < 1) || (dia > 28))
                                                msg = msg + lc + " deve possuir o dia entre 1 e 28.";
                                          }
                                       }
                                  }
                             }
                         }
                     }
                 }
              }
          }
          else
            msg = "Valida��o n�o pode ser realizada.<br> Tipo de dado do campo n�o identificado.";                                
          return msg;
   }                                                
// Funcao: MostraMsg
// Objetivo: Criar uma janela com uma pergunta (com op��o de sim/nao) ou uma informa��o (com OK)
// Parametros de Entrada:
//       frase: texto que deve ser exibido na janela
//       opcaobotoes: seleciona o tipo de bot�o que deve ser exibido.
//            "SN" = "Sim"/"N�o"
//            "TF" = "True"/"False"
//            <qualquer outra coisa> = "OK" 
// Parametros de Saida:
//       executa a funcao FecharWinMsg

function MostraMsg(frase,opcaobotoes)
{
  if (opcaobotoes == "SN") {
     if(confirm(frase) == true)
        FecharWinMsg("sim");
     else
        FecharWinMsg("nao");
  }
  else 
  {
     if (opcaobotoes == "TF") 
     {
        if(confirm(frase) == true)
           FecharWinMsg("true");
        else
           FecharWinMsg("false");

     }
     else 
     {
        alert(frase);
        FecharWinMsg("ok");
     }
  }
}

// Funcao: FecharWinMsg
// Objetivo: Fechar a janela de pergunta ou de informacao e retornar a op��o selecionada
// Parametros de Entrada: 
//    opcao = valor selecionado pelo usuario na pergunta
// Parametros de Saida: 
//    aux_dsretorn = valor selecionado pelo usuario na pergunta
//    Executa a funcao ZeraModoExclusao
function FecharWinMsg(opcao)
{

 if (opcao != null) {
    if ( opcao == "true" || opcao == "false" ) {                 
       top.mainFrame.document.form.aux_dsretorn.value = opcao;
       top.mainFrame.VoltaMensagem();
    }
    else {
         if (opcao != "ok") {                   
            top.mainFrame.document.form.aux_dsretorn.value = opcao; 
            if (modoexclusao == "sim") {
               ExcluirFinal();
            }
         }
    }
 }                 

 ZeraModoExclusao();
}
// Funcao: ZeraOp
// Objetivo: Assumir branco na variavel de tipo de operacao - aux_cddopcao
// Parametros de Entrada: nenhum
// Parametros de Saida: nenhum
function ZeraOp()
{
   top.mainFrame.document.form.aux_cddopcao.value = '';     
}
// Funcao: ZeraOpMag
// Objetivo: Assumir branco na variavel de retorno de funcoes - aux_dsretorn
// Parametros de Entrada: nenhum
// Parametros de Saida: nenhum
function ZeraOpMsg()
{
   top.mainFrame.document.form.aux_dsretorn.value = '';          
}
// Funcao: ZeraModoExclusao
// Objetivo: Assumir branco na variavel que indica se a tela est� em modo de exclusao - modoexclusao
// Parametros de Entrada: nenhum
// Parametros de Saida: nenhum
function ZeraModoExclusao()
{
   modoexclusao = '';
}
      
// Funcao: Incluir
// Objetivo: Funcao acionada quando selecionado o botao de incluir da tela
// Parametros de Entrada: nenhum
// Parametros de Saida: 
//    aux_cddopcao = 'in' - Modo de Inclusao
//    aux_stdopcao = 'i' - Status de Inclus�o
//    Funcao MostraResultado, caso o usu�rio n�o tenha permiss�o para inclus�o ou j� esteja em 
//       modo de inclus�o
function Incluir()
{
   ZeraModoExclusao()
   var vaux = top.mainFrame.document.form.aux_lspermis.value; 
   if (vaux.substring(0,1) == 'I') 
         { 
            if (top.mainFrame.document.form.aux_stdopcao.value == 'i') 
                  { 
                     MostraResultado('1','Voc� j� esta no modo de inclus�o.'); 
                     return false
                  } 
               else 
                  { 
                     top.mainFrame.document.form.aux_cddopcao.value='in'; 
                     top.mainFrame.document.form.aux_stdopcao.value='i'
                     top.mainFrame.LimparCampos(); 
                     return true
                  } 
         } 
      else 
         { 
            MostraResultado('1','Desculpe, mas voc� n�o tem permiss�o para executar esta fun��o.'); 
            return false
         }
}

// Funcao: ExcluirFinal
// Objetivo: Manda para o progress (submit() ) a instru��o de exclus�o do registro
// Parametros de Entrada: nenhum
// Parametros de Saida: 
//     aux_cddopcao = 'ex' - Opera��o de Exclus�o

function ExcluirFinal()
{
   ZeraModoExclusao()   
   if (top.mainFrame.document.form.aux_dsretorn.value == 'sim') 
   { 
      top.mainFrame.document.form.aux_cddopcao.value='ex';
      
      top.mainFrame.Habilita(); 
      top.mainFrame.HabilitaSalvar(); 
      top.mainFrame.document.form.submit(); 
      return true;
   }  
}

// Funcao: Excluir
// Objetivo: Funcao acionada quando selecionado o bot�o de Excluir da tela
// Parametros de Entrada: nenhum
// Parametros de Saida: 
//     Funcao MostraMsg, para confirmar a operacao, 
//     ou Funcao MostraResultado, caso o usu�rio n�o tenha a permiss�o de exclusao ou 
//        esteja em modo de inclus�o
function Excluir()
{
   ZeraModoExclusao();  
   var vaux = top.mainFrame.document.form.aux_lspermis.value; 
   if (vaux.substring(2,3) == 'E') { 
            if (top.mainFrame.document.form.aux_stdopcao.value=='i') { 
                     MostraResultado('1','Voc� esta no modo de inclus�o.Selecione o registro apropriado e ent�o selecione a op��o exclus�o.'); 
                     return false
                  } 
               else {
                     modoexclusao = "sim";
                     MostraMsg('Confirma a exclus�o do registro corrente?','SN');
                  } 
         } 
      else { 
            MostraResultado('1','Desculpe, mas voc� n�o tem permiss�o para executar esta fun��o.'); 
            return false
         }        
}

// Funcao: Salvar
// Objetivo: Funcao acionada quando selecionado o bot�o de Salvar da tela
// Parametros de Entrada: 
//    Funcao ValidaDados
// Parametros de Saida: 
//    aux_cddopcao = "sa" - Opera��o de Salvar
//    submit() - Manda para o progress a instru��o de salvar o registro
//    MostraResultado, caso o usu�rio n�o tenha permiss�o de Salvar
function Salvar()
   {
      ZeraModoExclusao();
      var vaux = top.mainFrame.document.form.aux_lspermis.value; 
      if ((vaux.substring(1,2) == 'A') || (top.mainFrame.document.form.aux_stdopcao.value == 'i')) { 
           if ( top.mainFrame.document.form.aux_cddopcao.value!='sa')  {
              if (top.mainFrame.ValidaDados(parent.mainFrame.document.forms[0])) {
                  top.mainFrame.Habilita(); 
                  top.mainFrame.HabilitaSalvar(); 
                  top.mainFrame.document.form.aux_cddopcao.value='sa'; 
                  top.mainFrame.status = 'Salvando. Por favor, aguarde ...'; 
                  top.mainFrame.document.form.submit(); 
                  return true;
               } 
               else { 
                 return false;
               }  
           } 
      }
      else { 
            MostraResultado('1','Desculpe, mas voc� n�o tem permiss�o para executar esta fun��o.'); 
            return false;
      }
   }

// Funcao: AbreZoom
// Objetivo: Funcao acionada quando selecionado o bot�o de Pesquisar da tela
// Parametros de Entrada: 
//    ProgramaDeZoom: Nome do programa de Pesquisa
//    ProgramaPrincipal: Nome do programa que chamou a pesquisa
//    NomeDoCampo: Nome do Campo da Tela a ser pesquisado (se aplic�vel)
//    TipoDeZoom: Identifica o tipo de Pesquisa. "P" para pesquisa de registro
//       <qualquer outra coisa> para pesquisa de um campo espec�fico da tela
//    ValorCampo...6: valores que s�o repassados para o programa de pesquisa eventualmente utilizar no
//       filtro de dados
// Parametros de Saida: 
//    Abre a janela de Pesquisa
function AbreZoom(ProgramaDeZoom,ProgramaPrincipal,NomeDoCampo,TipoDeZoom,ValorCampo,ValorCampo2,ValorCampo3,ValorCampo4,ValorCampo5,ValorCampo6,width,height)
   {
	  
      ZeraModoExclusao()   
      top.mainFrame.status = 'Processando pesquisa. Por favor, aguarde ...'; 
      if (ValorCampo == null)  ValorCampo = "";
      if (ValorCampo2 == null) ValorCampo2 = "";
      if (ValorCampo3 == null) ValorCampo3 = "";
      if (ValorCampo4 == null) ValorCampo4 = "";
      if (ValorCampo5 == null) ValorCampo5 = "";
      if (ValorCampo6 == null) ValorCampo6 = "";
      if (ValorCampo != "" )  ValorCampo = top.frames[0].Substituir(ValorCampo);  
      if (ValorCampo2 != "" ) ValorCampo2 = top.frames[0].Substituir(ValorCampo2);  
      if (ValorCampo3 != "" ) ValorCampo3 = top.frames[0].Substituir(ValorCampo3);  
      if (ValorCampo4 != "" ) ValorCampo4 = top.frames[0].Substituir(ValorCampo4);  
      if (ValorCampo5 != "" ) ValorCampo5 = top.frames[0].Substituir(ValorCampo5);  
      if (ValorCampo6 != "" ) ValorCampo6 = top.frames[0].Substituir(ValorCampo6);  
      ProgramaPrincipal = top.frames[0].Substituir(ProgramaPrincipal);   
      ProgramaDeZoom = top.mainFrame.document.form.aux_dsendurl.value + ProgramaDeZoom;   
      varurl = ProgramaDeZoom + '?Pesquisa='    + TipoDeZoom  + 
                                '&vprograma='   + ProgramaPrincipal + 
                                '&NomeDoCampo=' + NomeDoCampo + 
                                '&ValorCampo='  + ValorCampo  + 
                                '&ValorCampo2=' + ValorCampo2 + 
                                '&ValorCampo3=' + ValorCampo3 + 
                                '&ValorCampo4=' + ValorCampo4 + 
                                '&ValorCampo5=' + ValorCampo5 + 
                                '&ValorCampo6=' + ValorCampo6
      if (width == '' || width == undefined || width == null)
        width = '580';
      if (height == '' || height == undefined || height == null)
        height = '350';
      
      WZoom = window.open(varurl,'WZoom','toolbar=no,location=no,diretories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width='+width+',height='+height+',screenX=0,screenY=0,top=10,left=10');
      WZoom.focus();
   }

// Funcao: FechaPesquisa
// Objetivo: Funcao acionada ap�s sele��o de um registro na pesquisa
// Parametros de Entrada: 
//    vponteiro: Rowid do registro selecionado
// Parametros de Saida: 
//    Funcao FechaPesquisa com o rowid do registro selecionado
function FechaPesquisa(vponteiro)
{
   ZeraModoExclusao()   
   if (window.WZoom != null)
         {        
            if (WZoom.closed != true)
                  {
                     if (vponteiro != null)
                           top.mainFrame.FechaPesquisa(vponteiro);
                     WZoom.close();
                  }
         }
}

// Funcao: FechaZoom
// Objetivo: Funcao acionada ap�s sele��o de um registro na pesquisa que preenche o campo pesquisado com 
//    o valor selecionado
// Parametros de Entrada: 
//    campo: nome do campo pesquisado
//    valor...8: valores retornados pela pesquisa
// Parametros de Saida: 
//    Funcao RetornoDoZoom com as informa��es retornadas pela pesquisa
function FechaZoom(campo,valor,valor2,valor3,valor4,valor5,valor6,valor7,valor8)
{
   ZeraModoExclusao()   
   if (window.WZoom != null)
         {        
            if (WZoom.closed != true)
                  {
                     if (valor != null)
                           top.mainFrame.RetornoDoZoom(campo,valor,valor2,valor3,valor4,valor5,valor6,valor7,valor8);
                     WZoom.close();
                  }
         }
}

// Funcao: Substituir
// Objetivo: Troca caracteres que n�o podem ser passados como par�metros entre URLs
// Parametros de Entrada: 
//    str: string que ser� passada como par�metro
// Parametros de Saida: 
//    str: string j� com os caracteres especiais substituidos
function Substituir(str)
{ 
  re = / /gi;
  str=str.replace(re, "^");
  re = /&/gi;
  str=str.replace(re,"|");
  re = /=/gi;
  str=str.replace(re,"�");
  re = /'/gi;
  str=str.replace(re,"�");
  re = /"/gi;
  str=str.replace(re,"�");
  return str;
}

// Funcao: FormataData
// Objetivo: Preenche o campo de data com as barras, possibilitando que o usu�rio digite apenas 
//    os n�meros correspondentes � data
// Parametros de Entrada: 
//    campo: indica qual campo da tela deve ser formatado para data
//    teclapress: qual tecla o usu�rio pressionou
// Parametros de Saida: 
//    campo j� com a data formatada
function FormataData(campo,teclapress)  {
   
   var tecla = teclapress.keycode;
   vr = teclapress;
  
   vr = vr.replace(".",""); 
   vr = vr.replace("/",""); 
   tam = vr.length ;
           
   if ( tecla != 9 && tecla != 8 )   {
   
      if ( tam > 2 && tam < 5 )   
             top.mainFrame.document.form[campo].value = vr.substr(0, tam - 2) + '/' + vr.substr( tam - 2, tam );
          if ( tam > 5 && tam < 8 )  
             top.mainFrame.document.form[campo].value = vr.substr(0, 2) + '/' +
                    vr.substr( 2, 2) + '/' + vr.substr( 4, 4);
        }          
}

// Funcao: Decimal
// Objetivo: Troca v�rgula por ponto em um campo decimal
// Parametros de Entrada: 
//    dado: valor decimal que ser� passada como par�metro
// Parametros de Saida: 
//    valor: valor decimal j� com ponto ao inv�s de v�rgula
function Decimal(dado)
{
  var j=0;
  var valor="";
  dado=String(dado); 
    for (j=0;j<dado.length;j++) {
      if (dado.charCodeAt(j) != 46) {
         valor = valor + dado.substr(j,1);
      }
    } 
    re = /,/gi;
    valor=valor.replace(re, "."); 
    return valor;
}

// Funcao: Virgula
// Objetivo: Transforma o parametro de entrada em um decimal de duas casas
// Parametros de Entrada: 
//    dado: valor decimal que ser� passada como par�metro
// Parametros de Saida: 
//    valor2: valor decimal j� com duas casas decimais
function Virgula(dado)
{
  var valor="";
  var valor2="";
  var depois="nao";
  var h=0;
  dado=String(dado);
  for (i=0;i<dado.length;i++) 
  {
     if (dado.substr(i,1) != null) 
     {
        if (dado.charCodeAt(i) != 46)
        {
           if (dado.length == 1)
           {
              valor = dado.substr(i,1);
           }
           else
           {
              valor = valor + dado.substr(i,1);
           }
        }
        else  
        {
           valor = valor + ",";
        }      
     }  
  }
  for(i=0;i<valor.length;i++) 
  {
     if (h<3) 
     {
        valor2 = valor2 + valor.substr(i,1);
        if ((valor.substr(i,1) == ",") || (depois == "sim"))
        { 
           h = h  + 1;
           depois = "sim";
        }
     }
  }
  h=0;
  return valor2;
}

// Funcao: ComparaData
// Objetivo: Verifica se a data inicial � maior que a data final, e retorna a mensagem informada pelo usu�rio,
//    caso data inicial seja maior que a data final, ou branco caso contr�rio. 
// Parametros de Entrada: 
//    dtini: Data inicial a ser comparada
//    dtfim: Data final a ser comparada
//    mensagem: Frase que ser� retornada caso a data inicial seja maior do que a data final
// Parametros de Saida: 
//    aux_dsretorn: contendo a mensagem passada como parametro, ou ""(branco), caso a data inicial seja
//       menor ou igual � data final.
function ComparaData(dtini,dtfim,mensagem)
{
        p1  = dtini.indexOf("/") ;
    p2  = dtini.lastIndexOf("/") ;
    dia = dtini.substring(0,p1);
    mes = dtini.substring(p1+1,p2);
    ano = dtini.substring(p2+1,dtini.length);

    if (dia.toString().length == 1) 
       diaaux = "0" + dia.toString();
    else 
       diaaux = dia.toString();
  
    if (mes.toString().length == 1) 
       mesaux = "0" + mes.toString();
    else 
       mesaux = mes.toString();
        
    if (ano.toString().length == 1) {        
       if (ano > 50 ) 
          anoaux = "190" + ano.toString(); 
       else  
          anoaux = "200" + ano.toString(); 
    }        
    else {
      if (ano.toString().length == 2) {        
         if (ano > 50 ) 
            anoaux = "19" + ano.toString(); 
         else  
            anoaux = "20" + ano.toString(); 
      }
          else {
        if (ano.toString().length == 3) {        
           if (ano > 50 ) 
              anoaux = "1" + ano.toString(); 
           else  
              anoaux = "2" + ano.toString(); 
        }
            else {
               anoaux = ano.toString(); 
            }   
      }
        }   
    vdataini = mesaux + '/' + diaaux + '/' + anoaux;
        
        p1  = dtfim.indexOf("/") ;
    p2  = dtfim.lastIndexOf("/") ;
    dia = dtfim.substring(0,p1);
    mes = dtfim.substring(p1+1,p2);
    ano = dtfim.substring(p2+1,dtfim.length);

    if (dia.toString().length == 1) 
       diaaux = "0" + dia.toString();
    else 
       diaaux = dia.toString();
  
    if (mes.toString().length == 1) 
       mesaux = "0" + mes.toString();
    else 
       mesaux = mes.toString();
        
    if (ano.toString().length == 1) {        
       if (ano > 50 ) 
          anoaux = "190" + ano.toString(); 
       else  
          anoaux = "200" + ano.toString(); 
    }        
    else {
      if (ano.toString().length == 2) {        
         if (ano > 50 ) 
            anoaux = "19" + ano.toString(); 
         else  
            anoaux = "20" + ano.toString(); 
      }
          else {
        if (ano.toString().length == 3) {        
           if (ano > 50 ) 
              anoaux = "1" + ano.toString(); 
           else  
              anoaux = "2" + ano.toString(); 
        }
            else {
               anoaux = ano.toString(); 
            }   
      }
        }   
    vdatafim = mesaux + '/' + diaaux + '/' + anoaux;
        
    if ( Date.parse(vdatafim) < Date.parse(vdataini) )
          top.mainFrame.document.form.aux_dsretorn.value = mensagem;
        else
          top.mainFrame.document.form.aux_dsretorn.value = '';
}





