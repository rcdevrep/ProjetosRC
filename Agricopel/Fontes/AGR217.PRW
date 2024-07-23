#Include "Rwmake.ch"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR217   ºAutor  ³ALAN LEANDRO        º Data ³  28/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ IMPRESSAO DA AGENDA                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER Function AGR217()

	Local cPerg := "AGR217"

	Limite   := 80
	cString  :="SU6"
	cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir a agenda")
	cDesc2   := OemToAnsi("dos operadores.")
	cDesc3   := ""
	nChar    := 18
	cTamanho := "P"

	aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
	cNomeProg:= "AGR217"
	aLinha   := {}
	nLastKey := 0

	Titulo   := "Agenda do Operador"
	cCabec1  := "* DATA      CLIENTE                                                            *"
			//01234567890123456789012345678901234567890123456789012345678901234567890123456789
			//1        10        20        30        40        50        60        70        80
	cCabec2  := ""
	cCancel  := "***** CANCELADO PELO OPERADOR *****"
	m_pag    := 1        //Variavel que acumula numero da pagina
	wnrel    := "AGR217" //Nome Default do relatorio em Disco

	AGR217Perg(cPerg)

	SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	RptStatus({|lEnd| AGR217I(@lEnd,wnrel,cString)},Titulo)

Return

Static Function AGR217I(lEnd,wnRel,cString)

	Local nLin      := 99
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cOperador := ""
	Local cVendedor := ""
	Local cImptel   := "N"

	Local cNomcli  := ""
	Local cTelCli  := ""
	Local cMunCli  := ""
	Local cEstCli  := ""
	Local cVendCli := ""

	If (Empty(mv_par06))
		mv_par05 := 1
	EndIf

	cQuery := " SELECT SU6.U6_DATA,  SU6.U6_CODENT,  SU6.U6_HRINI,  SU6.U6_CONTATO, "
	cQuery += "        SA1.A1_NREDUZ, SA1.A1_DDD, SA1.A1_TEL, SA1.A1_MUN, SA1.A1_EST, A1_VEND2 "

	cQuery += " FROM " + RetSqlName("SU6") + " SU6 (NOLOCK), " + RetSqlName("SA1") + " SA1 (NOLOCK) "

	cQuery += " WHERE  SU6.D_E_L_E_T_ = '' "
	cQuery += " AND    SA1.D_E_L_E_T_ = '' "
	cQuery += " AND    SU6.U6_FILIAL =  '" + xFilial("SU6") + "'"
	cQuery += " AND    SA1.A1_FILIAL =  '" + xFilial("SA1") + "'"

	cQuery += " AND    SU6.U6_CODENT IN (SA1.A1_COD + SA1.A1_LOJA, SA1.A1_COD + ' ' + SA1.A1_LOJA) "

	cQuery += " AND    SU6.U6_ENTIDA = 'SA1' "
	cQuery += " AND    SU6.U6_STATUS = '1' "
	cQuery += " AND    SU6.U6_DATA BETWEEN '" + Dtos(mv_par02) + "' AND '" + Dtos(mv_par03) + "'"
	cQuery += " AND    SU6.U6_OPERAD = '" + mv_par01 + "'"

	If (mv_par05 > 1)
		cQuery += " AND SA1." + getCampoVend() + " = '" + mv_par06 + "'"
	EndIf

	cQuery += " ORDER BY  SU6.U6_DATA,  SU6.U6_HRINI,  SU6.U6_CODENT "

	TCQuery cQuery NEW ALIAS (cAliasQry)

	TcSetField(cAliasQry,"U6_DATA","D",08,0)    

	SU7->(dbSetOrder(1))
	If SU7->(dbSeek(xFilial("SU7")+mv_par01))
		cOperador := "Operador: " + AllTrim(SU7->U7_COD) + " - " + AllTrim(SU7->U7_NOME)
	Endif

	If (mv_par05 > 1)
		SA3->(dbSetOrder(1))
		SA3->(dbGoTop())
		If SA3->(dbSeek(xFilial("SA3")+mv_par06))
			cVendedor := "Vendedor: " + AllTrim(SA3->A3_COD) + " - " + AllTrim(SA3->A3_NOME)
		Endif
	EndIf

	Setregua((cAliasQry)->(Reccount()))
	While !(cAliasQry)->(Eof())

		IncRegua()

		If nLin > 55
			nLin := Cabec(Titulo,cCabec1,cCabec2,cNomeProg,cTamanho,nChar)
			nLin++ 

			If cImptel == "N" 
				@ nLin,000 PSAY cOperador

				If (mv_par05 > 1)
					nLin++
					@ nLin,000 PSAY cVendedor
				EndIf

				nLin++
				nLin++
				cImptel := "S"
			EndIf
		Endif

		cNomCli  := Substr((cAliasQry)->A1_NREDUZ,1,20) + "    " 
		cTelCli  := Alltrim((cAliasQry)->A1_DDD) + "/" + Alltrim((cAliasQry)->A1_TEL)
		cMunCli  := Alltrim(Substr((cAliasQry)->A1_MUN,1,18))
		cEstCli  := Alltrim((cAliasQry)->A1_EST)
		cVendCli := Alltrim((cAliasQry)->A1_VEND2)

		if (mv_par04 == 2 .Or. cVendCli == mv_par01)
			@ nLin,000 PSAY DTOC((cAliasQry)->U6_DATA)
			@ nLin,011 PSAY Substr((cAliasQry)->U6_CODENT,1,8) + " " + cNomCli + " " + cTelCli + " " + cMunCli + " " + cEstCli
			nLin++                                 
		EndIf

		(cAliasQry)->(dbSkip())
	Enddo

	(cAliasQry)->(dbCloseArea())


	Set Filter To

	SetPgEject(.F.)

	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return

Static Function AGR217Perg(cPerg)

	Local aRegistros  := {}

	AADD(aRegistros,{cPerg,"01","Operador      ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SU7"})
	AADD(aRegistros,{cPerg,"02","Periodo De    ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Periodo Ate   ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Somente Clientes do Operador ?","mv_ch4","N",01,0,0,"C","","mv_par04","Sim","","","Nao","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Tipo de Vendedor ","mv_ch5","N",01,0,0,"C","","mv_par05","Nenhum","","","Lubrificante","","","Rep Liquidos","","","RL Arla","","","RC Arla","",""})
	AADD(aRegistros,{cPerg,"06","Vendedor      ?","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SA3"})

	U_CriaPer(cPerg,aRegistros)

	Pergunte(cPerg,.F.)
Return

Static Function getCampoVend()

	Local _cVend := ""

	Do Case
		Case mv_par05 = 1
			_cVend := ""
		Case mv_par05 = 2
			_cVend := "A1_VEND"
		Case mv_par05 = 3
			_cVend := "A1_VEND3"
		Case mv_par05 = 4
			_cVend := "A1_VEND8"
		Case mv_par05 = 5
			_cVend := "A1_VEND7"
	EndCase

Return _cVend