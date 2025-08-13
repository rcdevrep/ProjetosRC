#INCLUDE "Totvs.CH"
#INCLUDE "PROTHEUS.CH"
#Include "RwMake.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/* 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Programa  ³ STAORGAN  ºAutor  ³ Jader Berto         Data ³ 19/04/2024     º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.  ³Organograma desenvolvido em HTML + ADVPL utilizando Google API º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                            	         º±±
±±º                                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso    ³ SIGAORG                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
*/   

User Function STAORGAN()
     

   Local aSize       := MsAdvSize()
   Local nPort       := 0
   Local oModal
   Local oWebEngine 
   //Local aArea := GetArea()
   Local aParamBox := {}
   Private oWebChannel
     
   Private cMensagem := " "

   Private cFile   := "C:\temp\organograma.htm"
   Private lEnd      := .F.
   Private lAbortPrint   := .F.
   Private CbTxt      := ""
   Private limite      := 150
   Private tamanho      := "G"
   Private nomeprog   := "ORGAN"
   Private nTipo      := 15
   Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
   Private nLastKey   := 0
   Private cPerg      := "ORGAN"
   Private cbcont      := 00
   Private CONTFL      := 01
   Private m_pag      := 01
   Private wnrel      := "ORGAN"
   Private _nReg      := 0
   Private cString      := "SE2"
   Private _nItPag      := 8
   Private nTamPed      := 0
   Private oPrint
   Private lVisImg
   Private cCodDepto
   Private cFuncao
   DEFAULT cTitle := "Organograma Empresarial"


     
    //Adicionando os parâmetros que serão utilizados
    aAdd( aParamBox,{1,"Departamento"  ,Space(15) ,""                           ,"","XYY","",0,.F.})  
    aAdd( aParamBox,{1,"Função"        ,Space(40) ,""                           ,"","","",0,.F.})  
    aAdd( aParamBox,{3,"Tipo de página", 1        ,{"Tela","HTML Local"}        ,50,"",.T.} )
    aAdd( aParamBox,{3,"Exibe foto"    , 1        ,{"Sim","Não"}                ,50,"",.T.} )
    aAdd( aParamBox,{3,"Tamanho"       , 1        ,{"Pequeno","Médio","Grande"}        ,50,"",.T.} )
    


    //Se a pergunta for confirmada
    If ParamBox( aParamBox, "Parâmetros para Consulta")
        //Se for a primeira opção será uma página de internet

        cFuncao  := MV_PAR02
        lVisImg  := (MV_PAR04 == 1)
        cCodDepto := Alltrim(MV_PAR01)
        __gerahtml() // Chamada para a montagem do HTML 

        If MV_PAR03 == 1

               oWebChannel := TWebChannel():New()


               
               //Cria a dialog
               DEFINE MSDIALOG oModal TITLE cTitle From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL // Usar sempre PIXEL !!!
               nPort := oWebChannel::connect()
               oWebEngine := TWebEngine():New(oModal, 0, 0, 100, 100,, nPort)
               //oWebEngine:cLang := FwRetIdiom() Only in smartclient higher than 19.3.1.0
               oWebEngine:bLoadFinished := {|self,cFile| conout("Fim do carregamento da pagina " + cFile) }
               oWebEngine:navigate(cFile)
               oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
               //TButton():New( 1, 1, "Salvar PDF", oModal, {|| oWebEngine:PrintPDF() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
               
               ACTIVATE DIALOG oModal CENTERED

          Else
               ShellExecute("Open", "C:\temp\organograma.htm", "", "", 1)
          EndIf
     
     Endif

  
    //RestArea(aArea)

Return

Static function __gerahtml()
Local   cTamanho
Private nSub := 0
private cJsonPess := ''
Private nConsulta := 0

   If !ExistDir("C:\temp")
        MakeDir("C:\temp")
   EndIf


   cMensagem += '<html>' + CRLF
   cMensagem += '  <head>' + CRLF
   cMensagem += '    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>' + CRLF
   cMensagem += '    	 <style type="text/css">' + CRLF
   cMensagem += '    		.img-arredondada {' + CRLF
   cMensagem += '    			width: 100px;' + CRLF
   cMensagem += '    			height: 100px;' + CRLF
   cMensagem += '    			border-radius: 50%;' + CRLF
   cMensagem += '    			object-fit: cover; ' + CRLF
   cMensagem += '    		}' + CRLF

   cMensagem += '			.google-visualization-orgchart-lineright{' + CRLF
   cMensagem += '			  border-right: 2px solid #027368 !important;' + CRLF
   cMensagem += '			}' + CRLF
			 
   cMensagem += '			.google-visualization-orgchart-lineleft{' + CRLF
   cMensagem += '			  border-left: 2px solid #027368 !important;' + CRLF
   cMensagem += '			  padding: 10px !important;' + CRLF
   cMensagem += '			}' + CRLF
			 
   cMensagem += '			.google-visualization-orgchart-linebottom {' + CRLF
   cMensagem += '   		  border-bottom: 2px solid #027368 !important;' + CRLF
   cMensagem += '			  padding: 10px !important;' + CRLF
   cMensagem += '			}' + CRLF

   cMensagem += '			.nome {' + CRLF
   cMensagem += '				color: #027368;' + CRLF
   cMensagem += '				font-size: 15px;' + CRLF
   cMensagem += '                  white-space: nowrap;' + CRLF
   cMensagem += '			}' + CRLF
   cMensagem += '			.depto {' + CRLF
   cMensagem += '				color: #048C7F;' + CRLF
   cMensagem += '				border-bottom: 1px solid;' + CRLF
   cMensagem += '				font-size: 13px;' + CRLF
   cMensagem += '				text-transform: uppercase;' + CRLF
   cMensagem += '                  white-space: nowrap;' + CRLF
   cMensagem += '			}' + CRLF
   cMensagem += '			.cargo {' + CRLF
   cMensagem += '				color: #72A6A1;' + CRLF
   cMensagem += '				font-size: 12px;' + CRLF
   cMensagem += '			}' + CRLF

   cMensagem += '     </style>' + CRLF
   cMensagem += '    <script type="text/javascript">' + CRLF
   cMensagem += '      google.charts.load("current", {packages:["orgchart"]});' + CRLF
   cMensagem += '      google.charts.setOnLoadCallback(drawChart);' + CRLF + CRLF
   

   cMensagem += '      function drawChart() {' + CRLF
   cMensagem += '        var data = new google.visualization.DataTable();' + CRLF
   cMensagem += '        data.addColumn("string", "Name");' + CRLF
   cMensagem += '        data.addColumn("string", "Manager");' + CRLF
   cMensagem += '        data.addColumn("string", "ToolTip");' + CRLF


   If MV_PAR05 == 1
       cTamanho := "small"
   ElseIf MV_PAR05 == 2
       cTamanho := "medium"
   Else
       cTamanho := "large"
   EndIf
     
     

   MsgRun("Carregando estrutura de Organograma...", "Por favor, Aguarde...", {|| Subordin('')  })
   
   

      


   cMensagem += '        data.addRows([' + CRLF
   cMensagem += cJsonPess + CRLF
   cMensagem += '        ]);' + CRLF

        // Create the chart.
   cMensagem += '        var chart = new google.visualization.OrgChart(document.getElementById("chart_div"));' + CRLF
        // Draw the chart, setting the allowHtml option to true for the tooltips.
   cMensagem += '        chart.draw(data, {"allowHtml":true, "size":"'+cTamanho+'", "allowCollapse":true});' + CRLF
   cMensagem += '      }' + CRLF

   cMensagem += '   </script>' + CRLF
   cMensagem += '    </head>' + CRLF
   cMensagem += '  <body>' + CRLF
   cMensagem += '    <div><button onclick="window.print()">Imprimir / Salvar PDF</button></div>' + CRLF
   cMensagem += '    <div id="chart_div"></div>' + CRLF
   cMensagem += '  </body>' + CRLF
   cMensagem += '</html>' + CRLF

 
   MemoWrite(cFile, cMensagem)
  /* 
   nRet := ShellExecute("open", cFile, "", "C:\", 1)
    */
Return



Static Function Subordin(cCPF)
Local cAlias	:= GetNextAlias()+cValToChar(nConsulta)
Local nTot
Local jPessoa
//Local aFuncs   := {}
Local aArea 
Local cPathFile
Local cNomeFile
Local cTagFoto
Local cFiltro := "%"
Local cBalao  := ""

     If Empty(cCPF)
          cFiltro += " AND SUP.CPFSUP = SUP.CPFSUP "
     Else
          cFiltro += " AND SUP.CPFSUP = '"+cCPF+"' "
     EndIf
     
     If !Empty(cCodDepto) 
          //cFiltro += " AND DEPARTAMENTO.CHAVEDP = DEPARTAMENTO.CHAVEDP "
     //Else
          cFiltro += " AND DEPARTAMENTO.CHAVEDP = '"+cCodDepto+"' "
     EndIf

     If !Empty(cFuncao) 
          cFuncao := Alltrim(cFuncao)
          cFiltro += " AND UPPER(FUNC.CARGO) LIKE UPPER('%"+cFuncao+"%') "
     EndIf

     cFiltro += "%"

     nConsulta++
     BeginSql Alias cAlias
          SELECT  DISTINCT    FUNC.RA_FILIAL,
				          FUNC.MATRICULA,
                              FUNC.CODDEPTO, 
                              FUNC.NOME,    
                              FUNC.CPF,   
                              SUP.SUPERIOR,  
                              FUNC.CARGO,
                              SUP.SUPCARGO,
                              DIVISAO.DIV,
                              SUP.CPFSUP,                                                  
                              FUNC.RA_BITMAP,
                              SUP.RA_FILIAL FILSUPER,
                              SUP.RA_BITMAP SUPBITMAP,
                              SUP.NOMESUP,
                              SUP.RA_SITFOLH SITFOLSUP
          FROM   
          (SELECT SRA.RA_FILIAL,
                         SRA.RA_MAT     AS MATRICULA,
                         SRA.RA_NOMECMP AS NOME,
                         SQB.QB_DEPTO   AS CODDEPTO, 
                         SQB.QB_XDIR	       AS IDDEP,
                         SQB.QB_XDIV        AS DIVISAO,
                         SQB.QB_MATRESP     AS SUPERIOR, 
                         SQB.QB_FILRESP     AS FILSUPER, 
                         SRJ.RJ_XCARING     AS CARGO,  
                         SRA.RA_CIC     AS CPF,
                         SRA.RA_BITMAP
                    FROM   SRA010 SRA,
                         SRJ010 SRJ,
                         SQB010 SQB,
                         SQ3010 SQ3
                    WHERE  SQ3.%NotDel% 
                         AND SRA.%NotDel% 
                         AND SQB.%NotDel% 
                         AND SRJ.%NotDel%
                         AND SRA.RA_SITFOLH <> 'D'
                         AND SRA.RA_DEPTO = SQB.QB_DEPTO
                         AND SRA.RA_CODFUNC = SRJ.RJ_FUNCAO 
                         AND SRA.RA_CARGO = SQ3.Q3_CARGO   
                         AND Substring(SRA.RA_FILIAL, 1, 2) = SRJ.RJ_FILIAL  
                         AND Substring(SRA.RA_FILIAL, 1, 2) = SQ3.Q3_FILIAL ) FUNC,  
               (SELECT DISTINCT X5_DESCRI DIV, 
                                   X5_CHAVE CHAVE  
                    FROM   SX5010 X5  
                         INNER JOIN SQB010 QB 
                                   ON QB.%NotDel%  
                                   AND X5.X5_CHAVE = QB_XDIV  
                    WHERE  X5.%NotDel%  
                         AND X5.X5_TABELA = 'ZY'  
                         AND X5.X5_CHAVE = QB_XDIV) DIVISAO,  
               (SELECT DISTINCT X5_DESCRI DEPART,   
                                   X5_CHAVE CHAVEDP 
                    FROM   SX5010 X5  
                         INNER JOIN SQB010 QB   
                                   ON QB.%NotDel%   
                                   AND X5.X5_CHAVE = QB_XDIR     
                    WHERE  X5.%NotDel%    
                         AND X5.X5_TABELA = 'XY'
                         AND X5.X5_CHAVE = QB_XDIR) DEPARTAMENTO,  
               (SELECT RA_NOMECMP SUPERIOR,  
                         RA_MAT,    
                         RA_FILIAL, 
                         RA_CIC AS CPFSUP,
                         RJ_XCARING  AS SUPCARGO,
                         RA_BITMAP,
                         RA_NOMECMP AS NOMESUP,
                         RA.RA_SITFOLH
                    FROM   SRA010 RA   
                         LEFT JOIN SQB010 QB    
                              ON RA.RA_FILIAL = QB.QB_FILRESP   
                                   AND RA.RA_MAT = QB.QB_MATRESP  
                                   AND RA.%NotDel%  
                                   AND QB.%NotDel% 
                         LEFT JOIN SRJ010 RJ ON  RA.RA_CODFUNC = RJ.RJ_FUNCAO ) SUP 
          WHERE DIVISAO.CHAVE = FUNC.DIVISAO   
               AND DEPARTAMENTO.CHAVEDP = FUNC.IDDEP    
               AND SUP.RA_FILIAL = FUNC.FILSUPER       
               AND SUP.RA_MAT = FUNC.SUPERIOR  
               AND SUP.SUPCARGO <> ''
               AND FUNC.CPF <> '06561029771'
               %exp:cFiltro%
          ORDER BY FUNC.CODDEPTO                       
     EndSql


     //---------------------------------------------------------------		
     // Retorno da quantidade de registros com mesmo cod.servico
     //---------------------------------------------------------------		
     Count To nTot		

     If nTot > 0
         ( cAlias )->(DbGoTop()) 
         While ( cAlias )->( !EOF() )


               //AADD(aFuncs, {(cAlias)->CPF, (cAlias)->NOME, (cAlias)->CARGO, (cAlias)->SUPERIOR, (cAlias)->SUPCARGO, (cAlias)->CPFSUP})
               cNomeFile := SubString((cAlias)->RA_FILIAL,1,2)+Alltrim((cAlias)->MATRICULA)+".jpg"
               cPathFile := "C:\temp\"+cNomeFile
               If lVisImg
                    If !File(cPathFile)
                         If RepExtract(Upper(AllTrim((cAlias)->RA_BITMAP)),cPathFile)
                              cTagFoto = '<img class="img-arredondada" src="'+cPathFile+'" />'
                         Else
                              cTagFoto = ''
                         EndIf
                    Else
                         cTagFoto = '<img class="img-arredondada" height=100px width=100px src="'+cPathFile+'" />'
                    EndIf
               Else
                    cTagFoto = replicate("&nbsp;",20)
               EndIf
                    
               jPessoa := JsonObject():New()
               jPessoa["v"] := fNome((cAlias)->NOME)
               cBalao := ''


               cBalao += '<div style=\"color:blue; font-style:italic\"></br>'+cTagFoto+'</div>' 
               cBalao += "<h1 class='nome'>"+fNome((cAlias)->NOME)+"</h1>"
               cBalao += "<h1 class='depto'>"+Capital(Alltrim((cAlias)->DIV))+"</h1>"
               cBalao += "<h1 class='cargo'>"+Capital(Alltrim((cAlias)->CARGO))+"</h1>"


               jPessoa["f"] := cBalao


               If nSub > 0
                    cJsonPess += ','
               EndIf


               cJsonPess += '['+jPessoa:toJson()+', "'+fNome((cAlias)->SUPERIOR)+'", "'+Capital(Alltrim((cAlias)->SUPCARGO))+'"]'



               //Adiciona foto do superior que não está na relação do departamento
               //If (fNome((cAlias)->SUPERIOR) $ cJsonPess)


               nSub++

               Subordin((cAlias)->CPF)

         (cAlias )->(DbSkip())
         End
     EndIf
     													
     (cAlias)->( dbCloseArea() )


Return 

Static Function fNome(cNome)
Local cNomeMod

     cNome := Alltrim(cNome)
     cNomeMod := Capital(SubStr(cNome,1, At(' ', cNome))) + Capital(SubStr(cNome,RAt(' ', cNome), Len(cNome)))

Return cNomeMod
