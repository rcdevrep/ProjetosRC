#INCLUDE "RWMAKE.CH"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*SIGAVILLE
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Cliente      ¦ AGRICOPEL                                               ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦Programa     ¦ AGR081A.PRW      ¦ Responsavel ¦ ALEXANDRE CAMARGO     ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦Descriçäo    ¦ ATUALIZACAO DO CONTAS A PAGAR VIA LEITORA OU MANUAL     ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Data        ¦ 29/05/01         ¦ Implantacao ¦                        ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Programador ¦ ALEXANDRE CAMARGO                                      ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Objetivos   ¦ MOSTRAR TELA DO CONTAS A PAGAR                          ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Arquivos    ¦ SE2 - Contas a Pagar                                    ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Indices     ¦ Todos os que o usuario escolher do arquivo.             ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Parametros  ¦                                                         ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Observacoes ¦                                                         ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Cuidados na ¦Salvar as Opcoes do Menu antes da atualizacao.           ¦¦¦
¦¦¦ Atualizacao ¦                                                         ¦¦¦
¦¦¦ de versao   ¦                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
SIGAVILLE */

User Function AGR081A()
Private	cCodBar
If !empty(SE2->E2_CODBAR)
	If SE2->E2_TPBAR == "L"
		cCodBar  := "LEITORA"
	ElseIf SE2->E2_TPBAR == "M"
		cCodBar  := "MANUAL"
	End
ElseIf empty(SE2->E2_CODBAR)
	cCodBar := "LEITORA"
End

Private aItems   := {"LEITORA","MANUAL"}

Private cNumero  := Space(47)
Private cCampo1  := space(05)
Private oCampo1  := Nil
Private cCampo2  := space(05)
Private oCampo2  := Nil
Private cCampo3  := space(05)
Private oCampo3  := Nil
Private cCampo4  := space(06)
Private oCampo4  := Nil
Private cCampo5  := space(05)
Private oCampo5  := Nil
Private cCampo6  := space(06)
Private oCampo6  := Nil
Private cCampo7  := space(01)
Private oCampo7  := Nil
Private cCampo8  := space(14)
Private oCampo8  := Nil

Private cCodMan := Space(47)
Private oCodMan := Nil

cNReduz  :=	Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NREDUZ")
cCGC     :=	Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_CGC")
cTipo    :=	Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_TIPO")
cFornece := "Fornecedor: "+SE2->E2_FORNECE+"  Loja: "+SE2->E2_LOJA+"    Nome: "+cNReduz
cTitulo	:= "Prefixo: "+SE2->E2_PREFIXO+ "    Numero: "+ SE2->E2_NUM + "    Parcela: "+SE2->E2_PARCELA
// cVencto  := Substr(SEF->EF_VENCTO,7,2)+'/'+Substr(SEF->EF_VENCTO,5,2)+'/'+Substr(SEF->EF_VENCTO,3,2) // dd/mm/aa
cVencto  := "Vencto: "+DTOC(SE2->E2_VENCTO)
cValor   := "Valor : "+STR(INT(SE2->E2_VALOR))+'.'+(STRZERO((SE2->E2_VALOR-INT(SE2->E2_VALOR))*100,2))

If cTipo == 'F'
	MsgInfo('Este Fornecedor possui cadastro Pessoa Fisica !')
Endif

If Empty(cCGC)
	MsgInfo('Este Fornecedor nao possui CGC !')
Endif

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Solicita Dados                                              ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 96,042 TO 323,635 DIALOG oDlg1 TITLE "Atualiza Contas a Pagar"
@ 04,010 TO 84,290

@ 08, 020 SAY cFornece
@ 15, 020 SAY cTitulo
@ 22, 020 SAY cVencto
@ 29, 020 SAY cValor

@ 45,020 SAY "Codigo de Barras:"
@ 45,080 COMBOBOX cCodBar ITEMS aItems SIZE 50,50 object oCodBar
oCodBar:Bchange := {||A833Muda()}

@ 60,020 SAY "Numero do Bloqueto Bancario:"  SIZE 200,7
@ 70,015 GET cCampo1 Object oCampo1
@ 70,035 GET cCampo2 Object oCampo2
@ 70,055 GET cCampo3 Object oCampo3
@ 70,075 GET cCampo4 Object oCampo4
@ 70,100 GET cCampo5 Object oCampo5
@ 70,120 GET cCampo6 Object oCampo6
@ 70,145 GET cCampo7 Object oCampo7
@ 70,155 GET cCampo8 Size 50,50 Object oCampo8
@ 70,017 Get cCodMan Size 200,50 Object oCodMan
A833Muda()
@ 91,200 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,250 BMPBUTTON TYPE 2 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 CENTER

RETURN NIL

Static Function OkProc()
If cCodBar == "MANUAL"
	cNumero := Alltrim(cCodMan)
	nTot    := Len(cNumero)
	cCaract := Space(01)
	nErros  := 0
	For _x := 1 to nTot
		cCaract := Substr(cNumero,_x,1)
		if empty(at(cCaract,"0123456789"))
			nErros := nErros + 1
		End
		cCaract := Space(01)
	Next _x
	
	If nErros <> 0
		msgstop("Codigo de Barras informado deve possuir apenas numeros")
		Return
	End
End

If cCodBar == "LEITORA"
	If Len(Alltrim(cCodMan)) <> 44 .And. Len(Alltrim(cCodMan)) > 0
		msgstop("Codigo de Barras lido nao possui 44 caracteres")
		Return
	End
End

Close(oDlg1)
Processa( {|| pCobBar() }, "Gravando Codigo de Barras" ,OemToAnsi(""),.F.)
Return

Static Function pCobBar

If cCodBar == "LEITORA"
	cNumero := alltrim(cCodMan)
	cNumAux := alltrim(cCodMan)
ElseIf cCodBar == "MANUAL"
	cCodMan := alltrim(cCampo1)+alltrim(cCampo2)+alltrim(cCampo3)+alltrim(cCampo4)+alltrim(cCampo5)+alltrim(cCampo6)+alltrim(cCampo7)+alltrim(cCampo8)
	cNumAux := cCodMan
	cSubVal := AllTrim(SubStr(cCodMan,38,10))
	cValor  := Strzero(Val(cSubVal),10)
	
	If AllTrim(SubStr(cCodMan,1,3)) == '237'  // Decompoem qdo digitado for Bradesco
		cNumero := AllTrim(SubStr(cCodMan,1,3))   +;   // Banco
		AllTrim(SubStr(cCodMan,4,1))   +;   // Moeda
		AllTrim(SubStr(cCodMan,33,1))  +;   // Dac
		AllTrim(SubStr(cCodMan,34,4))  +;   // Fator Vencimento
		cValor						 +;   // Valor
		AllTrim(SubStr(cCodMan,5,5))   +;   // Campo Livre
		AllTrim(SubStr(cCodMan,11,10)) +;   // Campo Livre
		AllTrim(SubStr(cCodMan,22,09)) +;   // Campo Livre
		'0'                                 // Zero Fixo cfe layout bradesco
	Else  // Decompoem qdo Digitado for outro Banco
		cNumero := AllTrim(SubStr(cCodMan,1,3))   +;   // Banco
		AllTrim(SubStr(cCodMan,4,1))   +;   // Moeda
		AllTrim(SubStr(cCodMan,33,1))  +;   // Dac do Codigo de barras
		AllTrim(Strzero(Val(SubStr(cCodMan,34,4)),4))  +;   // Fator Vencimento
		cValor						 +;   // Valor
		AllTrim(SubStr(cCodMan,5,5))   +;   // Campo Livre
		AllTrim(SubStr(cCodMan,11,10)) +;   // Campo Livre
		AllTrim(SubStr(cCodMan,22,10))      // Campo Livre
	EndIf
End

DbSelectArea("SE2")
Reclock("SE2",.F.)
If cCodBar == "LEITORA"
	SE2->E2_TPBAR := "L"
ElseIf cCodBar == "MANUAL"
	SE2->E2_TPBAR := "M"
End
SE2->E2_CODBAR := cNumero
SE2->E2_AUXBAR := cNumAux
msUnlock("SE2")

Close(oDlg1)
Return(.T.)

Static Function A833Muda()
If empty(SE2->E2_CODBAR)
	If cCodBar == "MANUAL"
		cCampo1 := space(05)
		cCampo2 := space(05)
		cCampo3 := space(05)
		cCampo4 := space(06)
		cCampo5 := space(05)
		cCampo6 := space(06)
		cCampo7 := space(01)
		cCampo8 := space(14)
	ElseIf cCodBar == "LEITORA"
		cCodMan := space(48)
	End
Else
	If cCodBar == "MANUAL"
		If SE2->E2_TPBAR == "M"
			cCampo1 := subs(SE2->E2_AUXBAR,1,5)
			cCampo2 := subs(SE2->E2_AUXBAR,6,5)
			cCampo3 := subs(SE2->E2_AUXBAR,11,5)
			cCampo4 := subs(SE2->E2_AUXBAR,16,6)
			cCampo5 := subs(SE2->E2_AUXBAR,22,5)
			cCampo6 := subs(SE2->E2_AUXBAR,27,6)
			cCampo7 := subs(SE2->E2_AUXBAR,33,1)
			cCampo8 := subs(SE2->E2_AUXBAR,34,14)
		ElseIf SE2->E2_TPBAR == "L"
			cCampo1 := space(05)
			cCampo2 := space(05)
			cCampo3 := space(05)
			cCampo4 := space(06)
			cCampo5 := space(05)
			cCampo6 := space(06)
			cCampo7 := space(01)
			cCampo8 := space(14)
		End
	ElseIf cCodBar == "LEITORA"
		If SE2->E2_TPBAR == "M"
			cCodMan := Space(48)
		ElseIf SE2->E2_TPBAR == "L"
			cCodMan := SE2->E2_CODBAR
		End
	End
Endif

If cCodBar == "LEITORA"
	oCampo1:Hide()
	oCampo1:Refresh()
	oCampo2:Hide()
	oCampo2:Refresh()
	oCampo3:Hide()
	oCampo3:Refresh()
	oCampo4:Hide()
	oCampo4:Refresh()
	oCampo5:Hide()
	oCampo5:Refresh()
	oCampo6:Hide()
	oCampo6:Refresh()
	oCampo7:Hide()
	oCampo7:Refresh()
	oCampo8:Hide()
	oCampo8:Refresh()
	oCodMan:Show()
	oCodMan:lReadOnly := .F.
	oCodMan:Refresh()
ElseIf cCodBar == "MANUAL"
	oCodMan:Hide()
	oCodMan:Refresh()
	oCampo1:Show()
	oCampo1:Refresh()
	oCampo2:Show()
	oCampo2:Refresh()
	oCampo3:Show()
	oCampo3:Refresh()
	oCampo4:Show()
	oCampo4:Refresh()
	oCampo5:Show()
	oCampo5:Refresh()
	oCampo6:Show()
	oCampo6:Refresh()
	oCampo7:Show()
	oCampo7:Refresh()
	oCampo8:Show()
	oCampo8:Refresh()
End
Return

//CONTA DE CONSUMO
User Function AGR081B()
Private	cCodBar

If !empty(SE2->E2_CODBAR)
	If SE2->E2_TPBAR == "L"
		cCodBar  := "LEITORA"
	ElseIf SE2->E2_TPBAR == "M"
		cCodBar  := "MANUAL"
	End
ElseIf empty(SE2->E2_CODBAR)
	cCodBar := "LEITORA"
End

Private aItems   := {"LEITORA","MANUAL"}

//If !empty(SE2->E2_CODBAR)

//	cCodBar  := "MANUAL"

//End

//Private aItems   := {"MANUAL"}

Private cNumero  := Space(48)
Private cCampo1  := space(11)
Private oCampo1  := Nil
Private cCampo2  := space(01)
Private oCampo2  := Nil
Private cCampo3  := space(11)
Private oCampo3  := Nil
Private cCampo4  := space(01)
Private oCampo4  := Nil
Private cCampo5  := space(11)
Private oCampo5  := Nil
Private cCampo6  := space(01)
Private oCampo6  := Nil
Private cCampo7  := space(11)
Private oCampo7  := Nil
Private cCampo8  := space(01)
Private oCampo8  := Nil

Private cCodMan := Space(48)
Private oCodMan := Nil

cNReduz  :=	Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NREDUZ")
cCGC     :=	Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_CGC")
cTipo    :=	Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_TIPO")
cFornece := "Fornecedor: "+SE2->E2_FORNECE+"  Loja: "+SE2->E2_LOJA+"    Nome: "+cNReduz
cTitulo	:= "Prefixo: "+SE2->E2_PREFIXO+ "    Numero: "+ SE2->E2_NUM + "    Parcela: "+SE2->E2_PARCELA
// cVencto  := Substr(SEF->EF_VENCTO,7,2)+'/'+Substr(SEF->EF_VENCTO,5,2)+'/'+Substr(SEF->EF_VENCTO,3,2) // dd/mm/aa
cVencto  := "Vencto: "+DTOC(SE2->E2_VENCTO)
cValor   := "Valor : "+STR(INT(SE2->E2_VALOR))+'.'+(STRZERO((SE2->E2_VALOR-INT(SE2->E2_VALOR))*100,2))

If cTipo == 'F'
	MsgInfo('Este Fornecedor possui cadastro Pessoa Fisica !')
Endif

If Empty(cCGC)
	MsgInfo('Este Fornecedor nao possui CGC !')
Endif

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Solicita Dados                                              ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 96,042 TO 323,635 DIALOG oDlg1 TITLE "Atualiza Contas a Pagar"
@ 04,010 TO 84,290

@ 08, 020 SAY cFornece
@ 15, 020 SAY cTitulo
@ 22, 020 SAY cVencto
@ 29, 020 SAY cValor

@ 45,020 SAY "Codido de Barras - Conta de Consumo:"
@ 45,125 COMBOBOX cCodBar ITEMS aItems SIZE 50,50 object oCodBar
oCodBar:Bchange := {||B833MudaB()}

@ 60,020 SAY "Numero da linha difitavel"  SIZE 200,7
@ 70,017 GET cCampo1 Size 50,60 Object oCampo1 //Object oCampo1
@ 70,057 GET cCampo2 Size 50,8 Object oCampo2 //Object oCampo2
@ 70,064 GET cCampo3 Size 50,60 Object oCampo3 //Object oCampo3
@ 70,102 GET cCampo4 Size 50,8 Object oCampo4 //Object oCampo4
@ 70,109 GET cCampo5 Size 50,60 Object oCampo5 //Object oCampo5
@ 70,147 GET cCampo6 Size 50,8 Object oCampo6 //Object oCampo6
@ 70,154 GET cCampo7 Size 50,60 Object oCampo7 //Object oCampo7
@ 70,192 GET cCampo8 Size 1,1 Object oCampo8 //Object oCampo8
@ 70,017 Get cCodMan Size 200,50 Object oCodMan
B833MudaB()
@ 91,200 BMPBUTTON TYPE 1 ACTION OkProcB()
@ 91,250 BMPBUTTON TYPE 2 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 CENTER

RETURN NIL

Static Function OkProcB()
If cCodBar == "MANUAL"
	cNumero := Alltrim(cCodMan)
	nTot    := Len(cNumero)
	cCaract := Space(01)
	nErros  := 0
	For _x := 1 to nTot
		cCaract := Substr(cNumero,_x,1)
		if empty(at(cCaract,"0123456789"))
			nErros := nErros + 1
		End
		cCaract := Space(01)
	Next _x
	
	If nErros <> 0
		msgstop("Codigo de Barras informado deve possuir apenas numeros")
		Return
	End
End

Close(oDlg1)
Processa( {|| pCobBarB() }, "Gravando Codigo de Barras" ,OemToAnsi(""),.F.)
Return

Static Function pCobBarB

If cCodBar == "LEITORA"
	cNumero := alltrim(cCodMan)
	cNumAux := alltrim(cCodMan)
ElseIf cCodBar == "MANUAL"

   cCodMan := alltrim(cCampo1)+alltrim(cCampo2)+alltrim(cCampo3)+alltrim(cCampo4)+alltrim(cCampo5)+alltrim(cCampo6)+alltrim(cCampo7)+alltrim(cCampo8)
   cNumAux := cCodMan
	
   cNumero := AllTrim(SubStr(cCodMan,01,11)) +;   // Campo Livre
   AllTrim(SubStr(cCodMan,12,01)) +;   // Campo Livre
   AllTrim(SubStr(cCodMan,13,11)) +;     // Campo Livre
   AllTrim(SubStr(cCodMan,24,01)) +;   // Campo Livre
   AllTrim(SubStr(cCodMan,25,11)) +;   // Campo Livre
   AllTrim(SubStr(cCodMan,36,01)) +;   // Campo Livre
   AllTrim(SubStr(cCodMan,37,11)) +;   // Campo Livre
   AllTrim(SubStr(cCodMan,48,01))   // Campo Livre

Endif

DbSelectArea("SE2")
Reclock("SE2",.F.)
If cCodBar == "LEITORA"
	SE2->E2_TPBAR := "L"
ElseIf cCodBar == "MANUAL"
	SE2->E2_TPBAR := "M"
End
SE2->E2_CODBAR := cNumero
SE2->E2_AUXBAR := cNumAux
msUnlock("SE2")

Close(oDlg1)
Return(.T.)

Static Function B833MudaB()
If empty(SE2->E2_CODBAR)
	If cCodBar == "MANUAL"
		cCampo1 := space(11)
		cCampo2 := space(01)
		cCampo3 := space(11)
		cCampo4 := space(01)
		cCampo5 := space(11)
		cCampo6 := space(01)
		cCampo7 := space(11)
		cCampo8 := space(01)
	ElseIf cCodBar == "LEITORA"
		cCodMan := space(48)
	End
Else
	If cCodBar == "MANUAL"
		If SE2->E2_TPBAR == "M"
			cCampo1 := subs(SE2->E2_AUXBAR,1,11)
			cCampo2 := subs(SE2->E2_AUXBAR,12,1)
			cCampo3 := subs(SE2->E2_AUXBAR,13,11)
			cCampo4 := subs(SE2->E2_AUXBAR,24,1)
			cCampo5 := subs(SE2->E2_AUXBAR,25,11)
			cCampo6 := subs(SE2->E2_AUXBAR,26,1)
			cCampo7 := subs(SE2->E2_AUXBAR,37,11)
			cCampo8 := subs(SE2->E2_AUXBAR,48,1)
		ElseIf SE2->E2_TPBAR == "L"
			cCampo1 := space(11)
			cCampo2 := space(01)
			cCampo3 := space(11)
			cCampo4 := space(01)
			cCampo5 := space(11)
			cCampo6 := space(01)
			cCampo7 := space(11)
			cCampo8 := space(01)
		End
	ElseIf cCodBar == "LEITORA"
		If SE2->E2_TPBAR == "M"
			cCodMan := Space(48)
		ElseIf SE2->E2_TPBAR == "L"
			cCodMan := SE2->E2_CODBAR
		End
	End
Endif

If cCodBar == "LEITORA"
	oCampo1:Hide()
	oCampo1:Refresh()
	oCampo2:Hide()
	oCampo2:Refresh()
	oCampo3:Hide()
	oCampo3:Refresh()
	oCampo4:Hide()
	oCampo4:Refresh()
	oCampo5:Hide()
	oCampo5:Refresh()
	oCampo6:Hide()
	oCampo6:Refresh()
	oCampo7:Hide()
	oCampo7:Refresh()
	oCampo8:Hide()
	oCampo8:Refresh()
	oCodMan:Show()
	oCodMan:lReadOnly := .F.
	oCodMan:Refresh()
ElseIf cCodBar == "MANUAL"
	oCodMan:Hide()
	oCodMan:Refresh()
	oCampo1:Show()
	oCampo1:Refresh()
	oCampo2:Show()
	oCampo2:Refresh()
	oCampo3:Show()
	oCampo3:Refresh()
	oCampo4:Show()
	oCampo4:Refresh()
	oCampo5:Show()
	oCampo5:Refresh()
	oCampo6:Show()
	oCampo6:Refresh()
	oCampo7:Show()
	oCampo7:Refresh()
	oCampo8:Show()
	oCampo8:Refresh()
End
Return