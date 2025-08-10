#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  REGRCONC   ºAutor  ³Jader Berto         º Data ³  01/10/24   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importador de Conciliação Bancária                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function REGRCONC()
Local aArea   := GetArea()
Local oBrowse
Private cCadastro := "Regras para Processamento"
Private aRotina		:= {}
     
    

    //Instânciando FWMBrowse, setando a tabela, a descrição
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZX2")
    oBrowse:SetDescription(cCadastro)
	aAdd(aRotina, {'Pesquisar' 		, 'PesqBrw'	, 0, 1, 0, Nil})
	aAdd(aRotina, {'Visualizar'		, 'AxVisual', 0, 2, 0, Nil})
	aAdd(aRotina, {'Incluir'   		, 'U_REGRINC', 0, 3, 0, Nil})
	aAdd(aRotina, {'Alterar'   		, 'U_REGRINC', 0, 4, 0, Nil})
	aAdd(aRotina, {'Excluir'   		, 'AxDeleta', 0, 5, 0, Nil})
	aAdd(aRotina, {'Copiar'   		, 'U_REGCOPY', 0, 6, 0, Nil})

    //Ativando a navegação
    oBrowse:Activate()

     
    RestArea(aArea)

Return


User Function REGRINC()

    Local aCOMBO      := {}
    Local CCOMBO      := ""
    Local aCbProc     := {}
    Local aCbProc2    := {}
    Local n1
    Local aFields
    Private cTextNat     := space(TamSx3("ED_CODIGO")[1])
    Private cTextStr    := space(254)
    Private cTextCli    := space(TamSx3("A1_COD")[1])
    Private cTextLoja   := space(TamSx3("A1_LOJA")[1])
    Private cTextBanc   := space(TamSx3("A6_COD")[1])
    Private cTextAgen   := space(TamSx3("A6_AGENCIA")[1])
    Private cTextCont   := space(TamSx3("A6_NUMCON")[1])
    Private cTextDVA    := space(TamSx3("A6_DVAGE")[1])
    Private cTextDVC    := space(TamSx3("A6_DVCTA")[1])
    Private cTextFIL    := cFilAnt
    Private oDlg
    Private cCbProc1      := ""
    Private cCbProc2      := ""
    Private cUltCamp  := ""
    Private oBtnMaior, oBtnMenor, oBtnIgual, oBtnDif, oBtnAdd, oBtnE, oBtnOU, oBtnTXT, oBtMAIQ, oBtMEIQ, oBtContem
    Private cMemoAdvp := ""
    Private oMemoAdvp
    Private cMemoLogi := "Se "
    Private oMemoLogi, oGetText, oGetNat, oGetCli, oGetFIL, oGetLoja, oGetBanc, oGetAgen, oGetCont, oGetDvAge, oGetDvCon

    If Altera
        cMemoLogi := ZX2->ZX2_EXPRES
        cMemoAdvp := ZX2->ZX2_ROTINA
        cTextCli  := ZX2->ZX2_CODCLI
        cTextLoja := ZX2->ZX2_LOJA
        cTextNat  := ZX2->ZX2_NATUR
        cTextBanc := ZX2->ZX2_BANCO
        cTextAgen := ZX2->ZX2_AGENCI
        cTextDVA  := ZX2->ZX2_DVAGEN
        cTextCont := ZX2->ZX2_CONTA
        cTextDVC  := ZX2->ZX2_DVCONT
        cTextFil  := ZX2->ZX2_FILPRC


        If ZX2->ZX2_PROCES == "2"
           cCbProc1 := "2-Baixa a Receber"
        ElseIf ZX2->ZX2_PROCES == "3"
            cCbProc1:= "3-Mov.Ban.Deb"
        ElseIf ZX2->ZX2_PROCES == "4"
            cCbProc1:= "4-Mov.Ban.Cred"
        EndIf

        If ZX2->ZX2_PROCE2 == "0" .OR. Empty(ZX2->ZX2_PROCE2)
            cCbProc2 := "0-Não Executar"
        ElseIf ZX2->ZX2_PROCE2 == "2"
           cCbProc2 := "2-Baixa a Receber"
        ElseIf ZX2->ZX2_PROCE2 == "3"
            cCbProc2:= "3-Mov.Ban.Deb"
        ElseIf ZX2->ZX2_PROCE2 == "4"
            cCbProc2:= "4-Mov.Ban.Cred"
        EndIf

    EndIf


    DEFINE MSDIALOG oDlg TITLE "Definição de Condição" FROM 10,10 TO 710,510 PIXEL

    aFields   := FWSX3Util():GetListFieldsStruct( "ZX6" , .T.)

    AADD(aCOMBO, "")

    For n1 := 1 To Len(aFields)
        If !("FILIAL" $ aFields[n1][1])
            AADD(aCOMBO, Alltrim(aFields[n1][1]) + " ("+Alltrim(RetTitle(aFields[n1][1]))+")")
        EndIf
    Next n1

    /*
    AADD(aCOMBO, "ZX6_BAIXA (Baixa)")
    AADD(aCOMBO, "ZX6_DTIMP (Data da Importação)")
    AADD(aCOMBO, "ZX6_HRIMP (Hora da Importação)")
    */

    // Campo Memo (várias linhas)
    @ 10,10 SAY "Construção de Condição para Processamento:" PIXEL
    @ -100,10 GET oMemoAdvp VAR cMemoAdvp MEMO SIZE 230,70 readonly PIXEL
    @ 20,10 GET oMemoLogi VAR cMemoLogi MEMO SIZE 230,90 readonly PIXEL

    // Botões de comparação
    @ 117,10 SAY "Campo:" PIXEL
    @ 127,10 COMBOBOX cCOMBO ITEMS aCOMBO SIZE 100,14 PIXEL OF oDlg
    @ 127,110 BUTTON oBtnAdd  PROMPT "Incluir" SIZE 30,13 ACTION (fUpdExp("ZX6->"+Substr(cCOMBO, 1 ,At("(",cCOMBO)-1),       Replace(Substr(cCOMBO, At("(",cCOMBO)+1 ,Len(cCOMBO)),")",""), 10)) PIXEL
  

    @ 117,150 SAY "Texto:" PIXEL
    @ 127,150 GET oGetText VAR cTextStr SIZE 70,11 PIXEL
    @ 127,220 BUTTON oBtnTXT  PROMPT "Incluir" SIZE 30,13 ACTION (fUpdExp(Alltrim(cTextStr),       Alltrim(cTextStr), 11)) PIXEL
  

    @ 145,10 BUTTON oBtnMaior PROMPT "Maior que " SIZE 40,13 ACTION (fUpdExp(" > ", " Maior que ", 3) ) PIXEL
    @ 145,55 BUTTON oBtnMenor PROMPT "Menor que " SIZE 40,13 ACTION (fUpdExp(" < ", " Menor que ", 4)) PIXEL
    @ 145,100 BUTTON oBtnIgual PROMPT "Igual a " SIZE 40,13 ACTION (fUpdExp(" = ", " Igual a ", 5)) PIXEL
    @ 145,145 BUTTON oBtnDif  PROMPT "Diferente de " SIZE 40,13 ACTION (fUpdExp(" <> ", " Diferente de ", 6)) PIXEL
    @ 145,190 BUTTON oBtnE  PROMPT "E" SIZE 13,13 ACTION (fUpdExp(" .AND. ", " E ", 7)) PIXEL
    @ 145,208 BUTTON oBtnOU  PROMPT "OU" SIZE 13,13 ACTION (fUpdExp(" .OR. ", " OU ", 8)) PIXEL
    @ 163,10 BUTTON oBtMAIQ PROMPT "Maior Ou Igual que " SIZE 60,13 ACTION (fUpdExp(" >= ", " Maior ou igual que ", -1) ) PIXEL
    @ 163,75 BUTTON oBtMEIQ PROMPT "Menor Ou Igual que " SIZE 60,13 ACTION (fUpdExp(" <= ", " Menor ou igual que ", -2)) PIXEL
    @ 163,140 BUTTON oBtContem PROMPT "Está Contido " SIZE 60,13 ACTION (fUpdExp(" $ ", " Está Contido ", -3 )) PIXEL

    @ 180,10 SAY "Parâmetros:" PIXEL
    @ 186,10 SAY "_____________________________________________________________________________" PIXEL

    
    @ 197,10 SAY "Filial:" PIXEL
    @ 207,10 MSGET oGetFIL VAR cTextFil SIZE 35,11 F3 "SM0" PIXEL
    
    @ 197,80 SAY "Cód.Cliente:" PIXEL
    @ 207,80 MSGET oGetCli VAR cTextCli SIZE 35,11 F3 "SA1" PIXEL
    
    @ 197,116 SAY "Loja:" PIXEL
    @ 207,116 GET oGetLoja VAR cTextLoja SIZE 10,11 PIXEL
    
    @ 197,160 SAY "Natureza:" PIXEL
    @ 207,160 MSGET oGetNat VAR cTextNat SIZE 35,11 F3 "SED" PIXEL

    @ 229,10 SAY "Dados Bancários para Segundo Movimento:" PIXEL
    @ 235,10 SAY "_____________________________________________________________________________" PIXEL
    
    @ 246,10 SAY "Banco:" PIXEL
    @ 256,10 MSGET oGetBanc VAR cTextBanc SIZE 15,11 F3 "SA6FIL" PIXEL
    
    @ 246,80 SAY "Agência:" PIXEL
    @ 256,80 GET oGetAgen VAR cTextAgen SIZE 30,11 PIXEL
    
    @ 246,110 SAY "Dv:" PIXEL
    @ 256,110 GET oGetDvAge VAR cTextDVA SIZE 10,11 PIXEL
    
    @ 246,160 SAY "Conta:" PIXEL
    @ 256,160 GET oGetCont VAR cTextCont SIZE 40,11 PIXEL
    
    @ 246,200 SAY "Dv:" PIXEL
    @ 256,200 GET oGetDvCon VAR cTextDVC SIZE 10,11 PIXEL

    //AADD(aCbProc, "1-Baixa a Pagar")
    AADD(aCbProc, "2-Baixa a Receber")
    AADD(aCbProc, "3-Mov.Ban.Deb")
    AADD(aCbProc, "4-Mov.Ban.Cred")

    

    @ 280,10 SAY "Executar:" PIXEL
    @ 286,10 SAY "_____________________________________________________________________________" PIXEL
    @ 297,10 COMBOBOX cCbProc1 ITEMS aCbProc SIZE 80,14 VALID {|| If(val(SubStr(cCbProc1,1,1)) == val(SubStr(cCbProc2,1,1)), FWAlertError("Escolha um movimento diferente!", "Seleção incorreta")  , .T.)} PIXEL OF oDlg
    

    AADD(aCbProc2, "0-Não Executar")
    AADD(aCbProc2, "2-Baixa a Receber")
    AADD(aCbProc2, "3-Mov.Ban.Deb")
    AADD(aCbProc2, "4-Mov.Ban.Cred")

    @ 297,160 COMBOBOX cCbProc2 ITEMS aCbProc2 SIZE 80,14 VALID {|| If(val(SubStr(cCbProc2,1,1)) == val(SubStr(cCbProc1,1,1)), FWAlertError("Escolha um movimento diferente!", "Seleção incorreta")  , .T.)} PIXEL OF oDlg





    // Botão para fechar a tela
    // Botão para fechar a tela
    @ 325,10 BUTTON "Gravar" SIZE 70,15 ACTION (fGrava()) PIXEL
    @ 325,90 BUTTON "Limpar" SIZE 70,15 ACTION (fLimpa()) PIXEL
    @ 325,170 BUTTON "Fechar" SIZE 70,15 ACTION oDlg:End() PIXEL

    oBtnMaior:lReadOnly := .T.
    oBtnMenor:lReadOnly := .T.
    oBtnIgual:lReadOnly := .T.
    oBtMAIQ:lReadOnly := .T.
    oBtMEIQ:lReadOnly := .T.
    oBtContem:lReadOnly := .T.
    oBtnDif:lReadOnly := .T.
    oBtnE:lReadOnly := .T.
    oBtnOU:lReadOnly := .T.

    oGetText:lReadOnly := .F.
    oBtnAdd:lReadOnly := .F.
    oBtnTXT:lReadOnly := .F.


    ACTIVATE MSDIALOG oDlg CENTERED

Return


Static Function fGrava()
Local aAreaZ := ZX6->(GEtArea())
Local cSeq

    If cCbProc2 == cCbProc1
         FWAlertError("Escolha um movimento diferente!", "Seleção incorreta")
         return
    EndIf

    IF(cCbProc1 != '2')
        DbSelectArea("SA6")
        SA6->(DbSetOrder(1))

        If !SA6->(DbSeek(PADR(SubStr(cTextFIL,1,2),4) + PADR(cTextBanc,TamSx3("A6_COD")[1]) + PADR(cTextAgen,TamSx3("A6_AGENCIA")[1]) + PADR(cTextCont,TamSx3("A6_NUMCON")[1])))
            FWAlertError("Conta bancária "+cTextBanc+" "+cTextAgen+" "+cTextCont +" não cadastrada na filial "+cTextFIL+".", "Seleção incorreta")
            return
        EndIf
    ENDIF
	
	

    DbSelectArea("ZX6")
    ZX6->(DbGoBottom())

    If valtype(&cMemoAdvp) # "L"
        FWAlertError ("Contém erros na expressão. Favor conferir.", "Lógica incorreta" )
        Return
    Else
        If Inclui
            cSeq := GetSxeNum("ZX2","ZX2_CDCOND")
        Else
            cSeq := ZX2->ZX2_CDCOND
        EndIf
        Reclock("ZX2",Inclui)
            ZX2->ZX2_CDCOND := cSeq
            ZX2->ZX2_EXPRES := cMemoLogi
            ZX2->ZX2_ROTINA := cMemoAdvp
            ZX2->ZX2_PROCES := SubStr(cCbProc1,1,1)
            ZX2->ZX2_PROCE2 := SubStr(cCbProc2,1,1)
            ZX2->ZX2_CODCLI := cTextCli
            ZX2->ZX2_LOJA   := cTextLoja
            ZX2->ZX2_NATUR  := cTextNat
            ZX2->ZX2_BANCO  := cTextBanc
            ZX2->ZX2_AGENCI := cTextAgen
            ZX2->ZX2_DVAGEN := cTextDVA
            ZX2->ZX2_CONTA  := cTextCont
            ZX2->ZX2_DVCONT := cTextDVC
            ZX2->ZX2_FILPRC := cTextFIL

        ZX2->(MsUnlock())
        If Inclui
            ZX2->(ConfirmSx8())
            FWAlertSuccess("Regra cadastrada com sucesso.", "Sucesso" )
        Else
            FWAlertSuccess("Regra alterada com sucesso.", "Sucesso" )
        EndIf

    EndIf
    oDlg:End()
    RestArea(aAreaZ)
Return

Static Function fUpdExp(cTxtAdvpl, cTxtLogi, nButton)



    If nButton == 10
        cUltCamp := cTxtAdvpl

        cMemoLogi += cTxtLogi
        cMemoAdvp += cTxtAdvpl

    ElseIf nButton == 11
        if(!EMPTY(cUltCamp))
            If TamSx3(SubStr(cUltCamp,6,10))[3] == "N"
                cMemoLogi += " número "+cTxtLogi    
                cMemoAdvp += cTxtAdvpl
            ElseIf TamSx3(SubStr(cUltCamp,6,10))[3] == "C"
                cMemoLogi += " "+cTxtLogi
                cMemoAdvp += "'"+cTxtAdvpl+"'" 
            ElseIf TamSx3(SubStr(cUltCamp,6,10))[3] == "D"
                If ValType(CTOD(cTxtAdvpl)) <> "D"
                    FWAlertError ("Formato de Data incorreto. Ex.: "+DTOC(Date()), "Formato de Data incorreto" )
                    Return
                ElseIf Empty(CTOD(cTxtAdvpl))
                    FWAlertError ("Formato de Data incorreto. Ex.: "+DTOC(Date()), "Formato de Data incorreto" )
                    Return
                EndIf
                cMemoLogi += " o dia "+cTxtLogi
                cMemoAdvp += " CTOD('"+cTxtAdvpl+"') " 
            ElseIf TamSx3(SubStr(cUltCamp,6,10))[3] == "M"
                cMemoLogi += " "+cTxtLogi
                cMemoAdvp += "'"+cTxtAdvpl+"'"
            ElseIf TamSx3(SubStr(cUltCamp,6,10))[3] == "L"
                If cTxtLogi == ".T."
                    cMemoLogi += " for verdadeiro "
                Else
                    cMemoLogi += " for falso "
                EndIf
                cMemoAdvp += cTxtAdvpl
            Else
                cMemoLogi += " "+cTxtLogi
                cMemoAdvp += "'"+cTxtAdvpl+"'" 
            Endif
        Else
            cMemoLogi += " "+cTxtLogi
            cMemoAdvp += "'"+cTxtAdvpl+"'" 
        endif
    Else

        cMemoLogi += cTxtLogi
        cMemoAdvp += cTxtAdvpl
    EndIf

    
    oMemoLogi:Refresh()
    oMemoAdvp:Refresh()


    If nButton < 10
        oBtnMaior:lReadOnly := .T.
        oBtnMenor:lReadOnly := .T.
        oBtnIgual:lReadOnly := .T.
        oBtMAIQ:lReadOnly := .T.
        oBtMEIQ:lReadOnly := .T.
        oBtContem:lReadOnly := .T.
        oBtnDif:lReadOnly := .T.
        oBtnE:lReadOnly := .T.
        oBtnOU:lReadOnly := .T.

        oGetText:lReadOnly := .F.
        oBtnAdd:lReadOnly := .F.
        oBtnTXT:lReadOnly := .F.
    ElseIf nButton == 11
        oBtnMaior:lReadOnly := .T.
        oBtnMenor:lReadOnly := .T.
        oBtnIgual:lReadOnly := .T.
        oBtMAIQ:lReadOnly := .T.
        oBtMEIQ:lReadOnly := .T.
        oBtContem:lReadOnly := .F.
        oBtnDif:lReadOnly := .T.
        oBtnE:lReadOnly := .F.
        oBtnOU:lReadOnly := .F.

        oGetText:lReadOnly := .T.
        oBtnAdd:lReadOnly := .T.
        oBtnTXT:lReadOnly := .T.
    Else
        oBtnMaior:lReadOnly := .F.
        oBtnMenor:lReadOnly := .F.
        oBtnIgual:lReadOnly := .F.
        oBtMAIQ:lReadOnly := .F.
        oBtMEIQ:lReadOnly := .F.
        oBtContem:lReadOnly := .F.
        oBtnDif:lReadOnly := .F.
        oBtnE:lReadOnly := .F.
        oBtnOU:lReadOnly := .F.

        oGetText:lReadOnly := .T.
        oBtnAdd:lReadOnly := .T.
        oBtnTXT:lReadOnly := .T.
    EndIf

Return

Static Function fLimpa()

    //oDlg:End()
    //U_REGRINC()
    cTextStr    := space(254)
    cUltCamp    := ""
    cMemoAdvp := ""
    cMemoLogi := "Se "
    oBtnMaior:lReadOnly := .T.
    oBtnMenor:lReadOnly := .T.
    oBtnIgual:lReadOnly := .T.
    oBtMAIQ:lReadOnly := .T.
    oBtMEIQ:lReadOnly := .T.
    oBtContem:lReadOnly := .T.
    oBtnDif:lReadOnly := .T.
    oBtnE:lReadOnly := .T.
    oBtnOU:lReadOnly := .T.

    oGetText:lReadOnly := .F.
    oBtnAdd:lReadOnly := .F.
    oBtnTXT:lReadOnly := .F.

Return

User Function REGCOPY()

    Local aAreaZ := ZX6->(GEtArea())
    Local cSeq
    Local cMemoLogi := ZX2->ZX2_EXPRES
    Local cMemoAdvp := ZX2->ZX2_ROTINA
    Local cCbProc1   := ZX2->ZX2_PROCES
    Local cCbProc2   := ZX2->ZX2_PROCE2
    Local cTextCli  := ZX2->ZX2_CODCLI
    Local cTextLoja := ZX2->ZX2_LOJA
    Local cTextNat  := ZX2->ZX2_NATUR
    Local cTextBanc := ZX2->ZX2_BANCO
    Local cTextAgen := ZX2->ZX2_AGENCI
    Local cTextDVA  := ZX2->ZX2_DVAGEN
    Local cTextCont := ZX2->ZX2_CONTA
    Local cTextDVC  := ZX2->ZX2_DVCONT

    cSeq := GetSxeNum("ZX2","ZX2_CDCOND")

    Reclock("ZX2", .T.)
        ZX2->ZX2_CDCOND := cSeq
        ZX2->ZX2_EXPRES := cMemoLogi
        ZX2->ZX2_ROTINA := cMemoAdvp
        ZX2->ZX2_PROCES := SubStr(cCbProc1,1,1)
        ZX2->ZX2_PROCE2 := SubStr(cCbProc2,1,1)
        ZX2->ZX2_CODCLI := cTextCli
        ZX2->ZX2_LOJA   := cTextLoja
        ZX2->ZX2_NATUR  := cTextNat
        ZX2->ZX2_BANCO  := cTextBanc
        ZX2->ZX2_AGENCI := cTextAgen
        ZX2->ZX2_DVAGEN := cTextDVA
        ZX2->ZX2_CONTA  := cTextCont
        ZX2->ZX2_DVCONT := cTextDVC

    ZX2->(MsUnlock())

    ZX2->(ConfirmSx8())


    FWAlertSuccess("Regra copiada com Sucesso!"+CRLF+"Núm: "+cSeq) 

    RestArea(aAreaZ)

Return


User Function SA6CONS()
	Local cTitulo		:= "Cadastro de Bancos"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "SA6"							//obrigatorio
	Local cCpoChave	    := "A6_COD" 					//obrigatorio
	Local cTitCampo	    := RetTitle(cCpoChave)			//obrigatorio
	Local cMascara	    := PesqPict(cAlias,cCpoChave)	//obrigatorio
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local cRetCpo		:= "M->A6_COD" 				//obrigatorio
	Local nColuna		:= 1	
	Local cCodigo		:= M->A6_COD					//pego o conteudo e levo para minha consulta padrão			
 	Private bRet 		:= .F.
    
    cQuery := " SELECT A6_COD, A6_AGENCIA, A6_NUMCON, A6_NREDUZ   "
	cQuery += " FROM "+RetSQLName("SA6") + " "
	cQuery += " WHERE A6_FILIAL = '" + SubStr(cTextFIL,1,2) + "' 
	cQuery += " AND D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY A6_COD, A6_AGENCIA, A6_NUMCON"
	

 	bRet := FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
Return(bRet)

Static Function FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
	Local nLista  
	Local cCampos 	:= ""
	Local bCampo	:= {}
	Local nCont		:= 0
	Local bTitulos	:= {}
	Local aCampos 	:= {}
	Local cTabela 
	Local cCSSGet		:= "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
	Local cCSSButton 	:= "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"
	Local cCSSButF3	:= "QPushButton {background-color: #ffffff;margin: 2px;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 3px; border-color: #C0C0C0;font: Normal 10px Arial;padding: 3px;} QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"
	Local bCampo
	Local nX
	
	Private _oLista	:= nil
	Private _oDlg 	:= nil
	Private _oCodigo
	Private _aDados 	:= {}
	Private _nColuna	:= 0
	
	Default cTitulo 	:= ""
	Default cCodigo 	:= ""
	Default nTamCpo 	:= 30
	Default _nColuna 	:= 1
	Default cTitCampo	:= RetTitle(cCpoChave)
	Default cMascara	:= PesqPict('"'+cAlias+'"',cCpoChave)

	_nColuna	:= nColuna

	If Empty(cAlias) .OR. Empty(cCpoChave) .OR. Empty(cRetCpo) .OR. Empty(cQuery)
		MsgStop("Os parametro cQuery, cCpoChave, cRetCpo e cAlias são obrigatórios!","Erro")
		Return
	Endif

	_cCodigo := Space(nTamCpo)
	_cCodigo := cCodigo

	cTabela:= CriaTrab(Nil,.F.)
	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)
     
	(cTabela)->(DbGoTop())
	If (cTabela)->(Eof())
		MsgStop("Não há registros para serem exibidos!","Atenção")
		Return
	Endif
   
	Do While (cTabela)->(!Eof())
		/*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
		cCampos	:= ""
		aCampos 	:= {}
		For nX := 1 TO FCount()
			bCampo := {|nX| Field(nX) }
			If ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
				if ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C"
					cCampos += "'" + (cTabela)->&(EVAL(bCampo,nX)) + "',"
				ElseIf ValType((cTabela)->&(EVAL(bCampo,nX)) )=="D"
					cCampos +=  DTOC((cTabela)->&(EVAL(bCampo,nX))) + ","
				Else
					cCampos +=  (cTabela)->&(EVAL(bCampo,nX)) + ","
				Endif
					
				aadd(aCampos,{EVAL(bCampo,nX),Alltrim(RetTitle(EVAL(bCampo,nX))),"LEFT",30})
			Endif
		Next
     
     	If !Empty(cCampos) 
     		cCampos 	:= Substr(cCampos,1,len(cCampos)-1)
     		aAdd( _aDados,&("{"+cCampos+"}"))
     	Endif
     	
		(cTabela)->(DbSkip())     
	Enddo
   
	(cTabela)->(DbCloseArea())
	
	If Len(_aDados) == 0
		MsgInfo("Não há dados para exibir!","Aviso")
		Return
	Endif
   
	nLista := aScan(_aDados, {|x| alltrim(x[1]) == alltrim(_cCodigo)})
     
	iif(nLista = 0,nLista := 1,nLista)
     
	Define MsDialog _oDlg Title "Consulta Padrão" + IIF(!Empty(cTitulo)," - " + cTitulo,"") From 0,0 To 280, 500 Of oMainWnd Pixel
	
	oCodigo:= TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| /*Processa({|| FiltroF3P(M->_cCodigo)},"Aguarde...")*/ },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
	oCodigo:SetCss(cCSSGet)	
	oButton1 := TButton():New(010, 212," &Pesquisar ",_oDlg,{|| Processa({|| FiltroF3P(M->_cCodigo) },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cCSSButton)	
	    
	_oLista:= TCBrowse():New(26,05,245,90,,,,_oDlg,,,,,{|| _oLista:Refresh()},,,,,,,.F.,,.T.,,.F.,,,.f.)
	nCont := 1
        //Para ficar dinâmico a criação das colunas, eu uso macro substituição "&"
	For nX := 1 to len(aCampos)
		cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDados[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
		nCont++
	Next
	_oLista:SetArray(_aDados)
	_oLista:bWhen 		 := { || Len(_aDados) > 0 }
	_oLista:bLDblClick  := { || FiltroF3R(_oLista:nAt, _aDados, cRetCpo)  }
	_oLista:Refresh()

	oButton2 := TButton():New(122, 005," OK "			,_oDlg,{|| Processa({|| FiltroF3R(_oLista:nAt, _aDados, cRetCpo) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cCSSButton)	
	oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cCSSButton)	

	Activate MSDialog _oDlg Centered	
Return(bRet)

Static Function FiltroF3P(cBusca)
	Local i := 0

	if !Empty(cBusca)
		For i := 1 to len(_aDados)
			//Aqui busco o texto exato, mas pode utilizar a função AT() para pegar parte do texto
			if UPPER(Alltrim(_aDados[i,_nColuna]))==UPPER(Alltrim(cBusca))
				//Se encontrar me posiciono no grid e saio do "For"			
				_oLista:GoPosition(i)
				_oLista:Setfocus()
				exit
			Endif
		Next
	Endif
Return

Static Function FiltroF3R(nLinha,aDados,cRetCpo)
	cCodigo 	:= aDados[nLinha,_nColuna]
	/*--------------------------------------------------*
	| Uso desta forma para campos como tGet por exemplo |
	*--------------------------------------------------*/
	//&(cRetCpo)	:= cCodigo 
	/*---------------------------------------------------------------------------*
	| Não esquecer de alimentar essa variável quando for f3 pois ela e o retorno |
	*---------------------------------------------------------------------------*/
    /*
	If Empty(aCpoRet)
		aAdd( aCpoRet, cCodigo )
	Else	
		aCpoRet[1]	:= cCodigo
	EndIf
    */

	bRet 		:= .T.

    cTextBanc   := Alltrim(aDados[nLinha, 1])
    cTextAgen   := Alltrim(aDados[nLinha, 2])
    cTextCont   := Alltrim(aDados[nLinha, 3])	
	
	_oDlg:End()
	oDlg:Refresh()

Return
