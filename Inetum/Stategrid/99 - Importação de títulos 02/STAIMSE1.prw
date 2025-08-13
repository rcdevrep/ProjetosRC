#include "totvs.ch"
#include "protheus.ch"
#INCLUDE  'TOPCONN.CH'
 
/* 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Programa  ³ STAIMSE1  ºAutor  ³ Jader Berto         Data ³ 27/04/2024    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.  ³Importação de Contas a Receber via CSV                         º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                            	          º±±
±±º                                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso    ³ SIGAORG                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
*/ 

User Function STAIMSE1()

    Local aArea  	:= GetArea()
    Local cTitulo	:= "Importação de Contas à Receber"
    Local nOpcao 	:= 0
    Local aButtons 	:= {}
    Local aSays    	:= {}
    Local cPerg		:= "STAIMSE1"
    Private cArquivo:= ""
    Private oProcess
    Private lRenomear:= .F.
    

 
    Pergunte(cPerg,.F.)
 
    AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para Contas à Receber"))
    AADD(aSays,"")
    AADD(aSays,OemToAnsi("Clique no botão PARAM para informar os parametros que deverão ser considerados."))
    AADD(aSays,"")
    AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))
 
    AADD(aButtons, { 1,.T.,{|o| nOpcao:= 1,o:oWnd:End()} } )
    AADD(aButtons, { 2,.T.,{|o| nOpcao:= 2,o:oWnd:End()} } )
    AADD(aButtons, { 5,.T.,{| | pergunte(cPerg,.T.)  } } )
 
    FormBatch( cTitulo, aSays, aButtons,,200,530 )
 
    if nOpcao = 1
        cArquivo:= Alltrim(MV_PAR01)
 
        if Empty(cArquivo)
            MsgStop("Informe o nome do arquivo!!!","Erro")
            return
        Endif
 
        oProcess := MsNewProcess():New( { || Importa() } , "Importação de registros " , "Aguarde..." , .F. )
        oProcess:Activate()
        
    EndIf
 
    RestArea(aArea)
 
Return



//Rotina de Importa~ção dos Títulos
Static Function Importa()
    Local cArqProc   := cArquivo+".processado"
    Local cLinha     := ""
    Local j, i
    Local lPrim      := .T.
    Local aCampos    := {}
    Local aDados     := {}
    Local aAuxEv     := {}
    Local aColsSEV   := {}
    Local atitulos   := {}
    Local nCont		 := 1
    Local aRespos    := {}
    Local nAtual
    Local cMsg       := ""
    Local cCliente   := ""
    Local cLoja      := ""
    Local dEmissao   := CTOD('')
    Local dVencto    := CTOD('')
    Local nValor     := 0
    Local lGravou    := .F.
    Local aArea      := GetArea()
    Local cNumSeq
    Local xFilOrig   := cFilAnt
    Local xCFilial   := cFilAnt
    Local cPrefixo
    Local nNat
    Local nPosValor
    Local nValorNat

    Private aLog 	 := {}
	PRIVATE lMsErroAuto	   := .F.
	PRIVATE lMsHelpAuto	   := .T.
	PRIVATE lAutoErrNoFile := .T.

    If !File(cArquivo)
        MsgStop("O arquivo " + cArquivo + " não foi encontrado. A importação será abortada!","[AEST904] - ATENCAO")
        Return
    EndIf

    FT_FUSE(cArquivo) //Abre o arquivo texto
    oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
    FT_FGOTOP() //coloca o arquivo no topo
    While !FT_FEOF()
        nCont++
        oProcess:IncRegua1('Validando Linha: ' + Alltrim(Str(nCont)))
        
        cLinha := FT_FREADLN()
        cLinha := ALLTRIM(cLinha)
    
        If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
            aCampos := Separa(cLinha,";",.T.)
            lPrim := .F.
        Else// gravar em outra variavel os registros
            AADD(aDados,Separa(cLinha,";",.T.))
        EndIf
    
        FT_FSKIP()
    EndDo

    FT_FUSE()

    DbSelectArea("SE1")
    SE1->(DBSetOrder(1))

    oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros
    
    For i:=1 to Len(aDados)
        

        oProcess:IncRegua1("Importando títulos..."+aDados[i,5]+"/"+aDados[i,6])
        
        atitulos := {}
        
        
    

        cMsg := ""

        cCliente   := ""
        cLoja      := ""
        dEmissao   := CTOD('')
        dVencto    := CTOD('')
        cPrefixo   := ''
        nValor     := 0
        lGravou    := .F.
        


        oProcess:SetRegua2(len(aCampos))
        For j:=1 to Len(aCampos)
            oProcess:IncRegua2('Processando coluna: ' + ALLTRIM(aCampos[j]))

            //Se as colunas de Titulo não estiverem vazias
            If !Empty(aDados[i,1])
                If ALLTRIM(aCampos[j]) == "E1_FILIAL"
                    xCFilial := Strzero(val(aDados[i,j]),4)
                    //RPCSetEnv(cEmpAnt,xCFilial)
                    cFilAnt := xCFilial
                    AADD(atitulos,{"E1_FILIAL", xCFilial, NIL})

                ElseIf ALLTRIM(aCampos[j]) == "E1_PREFIXO"
                    cPrefixo := aDados[i,j]
                    AADD(atitulos,{"E1_PREFIXO", cPrefixo, NIL})

                ElseIf ALLTRIM(aCampos[j]) == "E1_CLIENTE"
                    cCliente   := aDados[i,j]
                    AADD(atitulos,{"E1_CLIENTE", cCliente, NIL})
                
                ElseIf ALLTRIM(aCampos[j]) == "E1_LOJA"
                    cLoja   := Strzero(val(aDados[i,j]),2)
                    AADD(atitulos,{"E1_LOJA", cLoja, NIL})

                ElseIf ALLTRIM(aCampos[j]) == "E1_EMISSAO"
                    dEmissao := CTOD(aDados[i,j])
                    AADD(atitulos,{ALLTRIM(aCampos[j]), dEmissao, NIL})

                ElseIf ALLTRIM(aCampos[j]) == "E1_VENCTO"
                    dVencto := CTOD(aDados[i,j])
                    AADD(atitulos,{ALLTRIM(aCampos[j]), dVencto, NIL})
                    AADD(atitulos,{"E1_VENCREA", DataValida(dVencto), NIL})

                ElseIf ALLTRIM(aCampos[j]) == "E1_VALOR"
                    nValor := val(Replace(aDados[i,j],",","."))
                    AADD(atitulos,{"E1_VALOR", nValor, NIL})

        
                Else
                    If SubStr(ALLTRIM(aCampos[j]),1,3) # "EV_"
                        If TamSX3(aCampos[j])[3] == 'N' //numerico
                            AADD(atitulos,{ALLTRIM(aCampos[j]), VAL(aDados[i,j]), NIL})
                        ElseIf TamSX3(aCampos[j])[3] == 'D' //data
                            AADD(atitulos,{ALLTRIM(aCampos[j]), CTOD(aDados[i,j]), NIL})
                        Else //outros
                            AADD(atitulos,{ALLTRIM(aCampos[j]), aDados[i,j], NIL})
                        EndIf
                    EndIf

                EndIf
            EndIf
            If SubStr(ALLTRIM(aCampos[j]),1,3) == "EV_"
                If ALLTRIM(aCampos[j]) == "EV_RATEICC"
                    AADD(aAuxEv,{"EV_RATEICC", '2', NIL})
                ElseIf ALLTRIM(aCampos[j]) == "EV_RECPAG"
                    AADD(aAuxEv,{"EV_RECPAG", 'R', NIL})
                Else
                    If TamSX3(aCampos[j])[3] == 'N' //numerico
                        AADD(aAuxEv,{ALLTRIM(aCampos[j]), VAL(aDados[i,j]), NIL})
                    ElseIf TamSX3(aCampos[j])[3] == 'D' //data
                        AADD(aAuxEv,{ALLTRIM(aCampos[j]), CTOD(aDados[i,j]), NIL})
                    Else //outros
                        AADD(aAuxEv,{ALLTRIM(aCampos[j]), aDados[i,j], NIL})
                    EndIf
                EndIf
            EndIf
     
        Next j

        If !Empty(aAuxEv)
            
            AADD(aAuxEv  ,{"EV_RECPAG" , 'R', NIL})
            AADD(aAuxEv  ,{"EV_RATEICC", '2', NIL})   
            AADD(aColsSEV, aAuxEv)   
            aAuxEv := {}      
        Endif   

        //Se os dados do Título estiverem preenchidos, inclui o titulo
        If !Empty(atitulos)
            If !Empty(aColsSEV)
                nNat := 1 
                For nNat := 1 to len(aColsSEV)
                    nPosValor := aScan(aColsSEV[nNat], {|x| AllTrim(Upper(x[1])) == "EV_VALOR" })
                    nValorNat := aColsSEV[nNat][nPosValor][2]
                    AADD(aColsSEV[nNat]  ,{"EV_PERC" , 100/nValor*nValorNat, NIL})
                Next nNat
                AADD(atitulos,{"E1_MULTNAT", '1', NIL})
            EndIf
            cNumSeq    := fSeq(xCFilial, cPrefixo)
            AADD(atitulos,{"E1_NUM", cNumSeq, NIL})


            lMsErroAuto := .F.
            //Utilizar o MsExecAuto para incluir registros na tabela de tituloss, utilizando a opção 3
            //MSExecAuto({|x,y| FINA040(x,y)},atitulos,3, ,aColsSEV)
            MSExecAuto({|x,y,z,a,b| FINA040(x,y,z,a,b)}, atitulos, 3,/**/,aColsSEV)
            aColsSEV := {}
            //Caso encontre erro exibir na tela
            If lMsErroAuto
                
                aRespos := GetAutoGRLog()
                //Percorre todas as linhas do log e salva num arquivo txt
                For nAtual := 1 To Len(aRespos)
                    cMsg += aRespos[nAtual] + CRLF
                Next

                GravaLog(lGravou, cFilAnt,cCliente,cLoja,dEmissao,dVencto,nValor,cMsg)

            Else
                lGravou := .T.
                GravaLog(lGravou, cFilAnt,cCliente,cLoja,dEmissao,dVencto,nValor,"Gravado com Sucesso!")
            EndIf
        EndIf

    Next i

    IF(MV_PAR02==1)
        If File(cArqProc)
            fErase(cArqProc)
        Endif
        fRename(Upper(cArquivo), cArqProc)
    Endif	
    
    If Len(aLog) > 0
        MostraLog()
    Else
        ApMsgInfo("Importação de títulos efetuada com sucesso!","SUCESSO")
    EndIf

    RestArea(aArea)
    cFilAnt := xFilOrig

Return


//Função para gravar erros encontrados
Static Function GravaLog(lGravou, cXFil, cCliente, cLoja, dEmissao, dVencto, nValor, cMsg)

    Local cFile := "\SYSTEM\"+FUNNAME()+".LOG"
    Local cLine := ""

    DEFAULT cMsg  := NIL

    If cMsg == NIL
        Begin Sequence
            IF !( lOk := File( cFile ) )
                Break
            EndIF
    
            FT_FUSE(cFile)
            FT_FGOTOP()
    
            While !FT_FEOF()
        
                cLine += FT_FREADLN() + CHR(13)+CHR(10)
        
                FT_FSKIP()
            End While
    
            FT_FUSE()
        End Sequence
    
        cMsg := cLine
    EndIf

    AADD(aLog,{lGravou, cXFil, cCliente,cLoja,dEmissao,dVencto,nValor,cMsg})

Return



//Função para mostrar log em tela
Static Function MostraLog()

    Local oDlg
    Local oFont
    Local cMemo := ""
    Private oOk 	   := LoadBitmap( GetResources(), "LBOK" )
	Private oNo 	   := LoadBitmap( GetResources(), "LBNO" )

    DEFINE FONT oFont NAME "Courier New" SIZE 5,0

    DEFINE MSDIALOG oDlg TITLE "Importação - Títulos à Receber" From 3,0 to 400,600 PIXEL

    aCabec := {"","Filial","Cliente","Loja","Emissão","Vencimento","Valor"}
    cCabec := "{If(aLog[oBrw:nAT][1],oOK,oNO), aLog[oBrw:nAT][2],aLog[oBrw:nAT][3],aLog[oBrw:nAT][4],aLog[oBrw:nAT][5],aLog[oBrw:nAT][6],aLog[oBrw:nAT][7]}"
    bCabec := &( "{ || " + cCabec + " }" )

    oBrw := TWBrowse():New( 005,005,290,090,,aCabec,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    oBrw:SetArray(aLog)
    oBrw:bChange    := { || cMemo := aLog[oBrw:nAT][8], oMemo:Refresh()}
    oBrw:bLDblClick := { || cMemo := aLog[oBrw:nAT][8], oMemo:Refresh()}
    oBrw:bLine := bCabec

    @ 100,005 GET oMemo VAR cMemo MEMO SIZE 290,080 OF oDlg PIXEL

    oMemo:bRClicked := {||AllwaysTrue()}
    oMemo:lReadOnly := .T.
    oMemo:oFont := oFont

    oImprimir :=tButton():New(185,120,'Imprimir' ,oDlg,{|| fImprimeLog() },40,12,,,,.T.)
    oSair     :=tButton():New(185,165,'Sair'     ,oDlg,{|| ::End() },40,12,,,,.T.)

    ACTIVATE MSDIALOG oDlg CENTERED

Return



//Função para mostrar o log impresso
Static Function fImprimeLog()

    Local oReport

    If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
        oReport := ReportDef()
        oReport:PrintDialog()
    EndIf

Return

Static Function ReportDef()

    Local oReport
    Local oSection

    oReport := TReport():New(FUNNAME(),"Importação - Títulos à Receber",,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de erros encontrados durante o processo de importação dos dados.")
    oReport:SetLandscape()

    oSection := TRSection():New(oReport,,{})

    TRCell():New(oSection,"FILIAL"  ,,"Filial")
    TRCell():New(oSection,"CLIENTE" ,,"Cliente")
    TRCell():New(oSection,"LOJA"    ,,"Loja")
    TRCell():New(oSection,"EMISSAO" ,,"Emissão")
    TRCell():New(oSection,"VENCTO"  ,,"Vencimento")
    TRCell():New(oSection,"VALOR"   ,,"Valor")
    TRCell():New(oSection,"DESCRI"  ,,"Descrição do Erro")

Return oReport

Static Function PrintReport(oReport)

    Local oSection := oReport:Section(1)
    Local nCurrentLine
    Local i

    oReport:SetMeter(Len(aLog))

    oSection:Init()

    For i:=1 to Len(aLog)
    
        If oReport:Cancel()
            Exit
        EndIf
    
        oReport:IncMeter()
    
        oSection:Cell("FILIAL"):SetValue(aLog[i,2])
        oSection:Cell("FILIAL"):SetSize(20)
        oSection:Cell("CLIENTE"):SetValue(aLog[i,3])
        oSection:Cell("CLIENTE"):SetSize(40)
        oSection:Cell("LOJA"):SetValue(aLog[i,4])
        oSection:Cell("LOJA"):SetSize(20)
        oSection:Cell("EMISSAO"):SetValue(aLog[i,5])
        oSection:Cell("EMISSAO"):SetSize(40)
        oSection:Cell("VENCTO"):SetValue(aLog[i,6])
        oSection:Cell("VENCTO"):SetSize(40)
        oSection:Cell("VALOR"):SetValue(aLog[i,7])
        oSection:Cell("VALOR"):SetSize(40)
        oSection:Cell("DESCRI"):SetValue(aLog[i,8])
        oSection:Cell("DESCRI"):SetSize(200)
    
        nTamLin := 200
        nTab := 3
        lWrap := .T.
    
        lPrim := .T.
    
        cObsMemo := aLog[i,8]
        nLines   := MLCOUNT(cObsMemo, nTamLin, nTab, lWrap)
    
        For nCurrentLine := 1 to nLines
            If lPrim
                oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
                oSection:Cell("DESCRI"):SetSize(300)
                oSection:PrintLine()
                lPrim := .F.
            Else
                oSection:Cell("FILIAL"):SetValue("")
                oSection:Cell("CLIENTE"):SetValue("")
                oSection:Cell("LOJA"):SetValue("")
                oSection:Cell("EMISSAO"):SetValue("")
                oSection:Cell("VENCTO"):SetValue("")
                oSection:Cell("VALOR"):SetValue("")
                oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
                oSection:Cell("DESCRI"):SetSize(300)
                oSection:PrintLine()
            EndIf
        Next i
    
        oReport:SkipLine()
    Next i

    oSection:Finish()

Return




Static Function fSeq(xCFilial, cPrefixo)
Local cSql := ""
Local cNum := "0"

	cSql  += " SELECT MAX(E1_NUM) ULTNUM FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xCFilial+"' AND E1_PREFIXO = '"+cPrefixo+"' "

	If ( Select("QRY1") > 0 )
		QRY1->( dbCloseArea() )
	EndIf

	TcQuery cSql Alias "QRY1" New

	IF !QRY1->(EOF())   
        cNum := QRY1->ULTNUM
    EndIf

    cNum := Soma1(cNum)


Return cNum
