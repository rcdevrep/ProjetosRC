#INCLUDE "PROTHEUS.CH"

User Function SMSCNPJ(cCnpj)
Local aCNPJ
Local aCNPJCTe
Local nPos  := 0
Local lCNPJ := .F.
Local lLim  := .F.
Local lCTE  := .F.
Local cData := ""


	// Validação para versão completa do produto
	aCNPJ := {{'00821995000151', '15/10/2014', .F.},; //CNPJ FAMAK
			{cCnpj			, '31/12/2020',.T.},;//TADEU - LIBERA ALL
	        {'              ', '  /  /    ',.F.},;
	        {'              ', '  /  /    ',.F.},;
	        {'              ', '  /  /    ',.F.},; 
	        {'              ', '  /  /    ',.F.},;
	        {'              ', '  /  /    ',.F.},;
	        {'              ', '  /  /    ',.F.},;
	        {'              ', '  /  /    ',.F.},;
	        {'              ', '  /  /    ',.F.};
		   		}
	nPos  := AScan(aCNPJ, {|x| cCNPJ == x[1]})

	If nPos > 0
		lCNPJ := .T.
		cData := aCNPJ[nPos][2]

		If aCNPJ[nPos][3]
			lLim := .T.
		Else
			If Date() > CToD(aCNPJ[nPos][2])
				lLim := .F.
			else
				lLim := .T.
			EndIf
		EndIf
	EndIf


	// Validação para versão apenas do CTe
	If !lCNPJ

		aCNPJCTe := {	{'00821995000151', '15/10/2014', .F.},;
						{cCnpj			 , '31/12/2020',.T.}}

		nPos     := AScan(aCNPJCTe, {|x| cCNPJ == x[1]})

		If nPos > 0

			lCTe  := .T.
			lCNPJ := .T.
			cData := aCNPJCTe[nPos][2]

			If aCNPJCTe[nPos][3]
				lLim := .T.
			Else
				If Date() > CToD(aCNPJCTe[nPos][2])
					lLim := .F.
				EndIf
			EndIf
		EndIf
	Endif


Return {&(Embaralha("BAEEaTmmsIbbe'aa) rr,+aa  ll0chh)Uaa,s(( eMD1rDT,N5o a(C4mS()eud )bD+,Sa  tt'0raG)(", 1)), lCNPJ, lLim, cData, lCTe}
