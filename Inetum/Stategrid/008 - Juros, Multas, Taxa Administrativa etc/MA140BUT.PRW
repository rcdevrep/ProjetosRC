#INCLUDE "TOTVS.CH"

User Function MA140BUT()
Local aButtons  := {}
Public _cCamNovo1 := SF1->F1_XMULTA
Public _cCamNovo2 := SF1->F1_XJUROS


//aadd(aButtons,{"Anexos",{ || U_TOTVSANEXO(cEmpAnt,cFilAnt,'NF',SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA ) )},"Anexos","Anexos"})
aadd(aButtons,{"Anexos",{ || U_STAN140()  },"Anexos","Anexos"})
aadd(aButtons,{"Anexos",{ || U_XADTPRE()  },"Adiantamentos de Pedidos","Adiantamentos de Pedidos"})
aadd(aButtons,{"Anexos",{ || U_XADTHLD()  },"Adiantamentos de Contratos","Adiantamentos de Contratos"})
aadd(aButtons,{"Anexos",{ || U_XREPLOC()  },"Replicar Armazem","Replicar Armazem"})
aadd(aButtons,{"Anexos",{ || JurMult()    },"Juros/Multa","Juros/Multa"})


Return (aButtons) 

User Function STAN140() 
	
	if  empty(CNFISCAL)  .or.  empty(CA100FOR) .or.  empty(CLOJA)
		MsgInfo("Preencha o Cabeçalho da Nota Fiscal.", "Atenção")	
	else
		If Len(AllTrim(CLOJA)) == 2
			U_TOTVSANEXO(cEmpAnt,cFilAnt,'NF',CNFISCAL+CSERIE+CA100FOR+CLOJA)
		Else
			U_TOTVSANEXO(cEmpAnt,cFilAnt,'NF',CNFISCAL+CSERIE+CA100FOR+AllTrim(CLOJA))
		EndIf
	endif
	
Return 

User Function XREPLOC()

	Local nX

	If INCLUI .or. ALTERA

		cArm := aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOCAL"})]

		if MsgYesno("Replicar este armazém (" + cArm + ") para todas as linhas","Totvs")

			For nx:=1 to len(acols)

				aCols[nx][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOCAL"})] := cArm

			Next nx

		endif

	EndIf

Return




Static Function JurMult()
Local cPedido := aCols[1][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_PEDIDO'})]
Local lPed    := .F.
Local lEdit   := .T.
   //Se for inclusão, irá criar a variável e será editável, senão irá buscar do banco e não será editável
    If SC7->(DbSeek(xFilial("SC7") + cPedido))
        If SC7->C7_XMULTA > 0
            _cCamNovo1 := SC7->C7_XMULTA
        EndIf
        If SC7->C7_XJUROS > 0
            _cCamNovo2 := SC7->C7_XJUROS
        EndIf
        lPed := .T.
    EndIf
    If !lPed
        If INCLUI
            If M->F1_XMULTA <> Nil
                _cCamNovo1 := M->F1_XMULTA
                _cCamNovo2 := M->F1_XJUROS
            Else
                _cCamNovo1 := CriaVar("F1_XMULTA",.F.)
                _cCamNovo2 := CriaVar("F1_XJUROS",.F.)
            EndIf
            lEdit := .T.
        Else
            If M->F1_XMULTA <> Nil
                _cCamNovo1 := M->F1_XMULTA
                _cCamNovo2 := M->F1_XJUROS
            Else
                _cCamNovo1 := SF1->F1_XMULTA
                _cCamNovo2 := SF1->F1_XJUROS
            EndIf
            lEdit := .T.
        EndIf
    EndIf

	DEFINE MSDIALOG oDlg TITLE "Aplicação de Juros e Multa" FROM 000, 000  TO 115, 220 COLORS 0, 16777215 PIXEL
  
    //Criando na janela o campos customizados
    @ 003, 003 SAY Alltrim(RetTitle("F1_XMULTA")) OF oDlg PIXEL SIZE 050,006
    @ 001, 025 MSGET oCampo VAR _cCamNovo1 PICTURE "@E 999,999,999.99" SIZE 70, 006 OF oDlg COLORS 0, 16777215  PIXEL
    oCampo:bHelp := {|| ShowHelpCpo( "F1_XMULTA", {GetHlpSoluc("F1_XMULTA")[1]}, 5  )}
  
  
    //Criando na janela o campos customizados
    @ 015, 003 SAY Alltrim(RetTitle("F1_XJUROS")) OF oDlg PIXEL SIZE 050,006
    @ 014, 025 MSGET oCampo2 VAR _cCamNovo2 PICTURE "@E 999,999,999.99" SIZE 70, 006 OF oDlg COLORS 0, 16777215  PIXEL
    oCampo2:bHelp := {|| ShowHelpCpo( "F1_XJUROS", {GetHlpSoluc("F1_XJUROS")[1]}, 5  )}

    //Se não houver edição, desabilita os gets
    If ! lEdit
        oCampo:lActive := .F.
        oCampo2:lActive := .F.
    EndIf
 
		DEFINE SBUTTON oSButton1 FROM 040, 035 TYPE 01 OF oDlg ENABLE ACTION Processa({|| oDlg:End() },,"Gravando....")
		//DEFINE SBUTTON oSButton2 FROM 040, 060 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

Return
