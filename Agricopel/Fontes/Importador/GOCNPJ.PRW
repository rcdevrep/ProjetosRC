#INCLUDE "PROTHEUS.CH"

User Function GOCNPJ()
	
	Local aCNPJ
	Local cCNPJ := PARAMIXB[1]
	Local nPos  := 0
	Local lCNPJ := .T.
	Local cData := ""
	Local lLim  := .F.
	
	/*Array que deve conter os CNPJ'S das empresas que poderão utilizar o importador, Data Limite e se está liberado permanentemente para uso
	  ficando com a seguinte estrutura
		
		{ {[CNPJ], [Data Limite], [Liberado]},
		  {[CNPJ], [Data Limite], [Liberado]},
		  ...
		  ...
		  Exemplo
		  {'11111111111111', '05/05/2014', .F.}
		}
	  
	  Caso o elemento [Liberado] seja colocado como .T., independente da Data Limite, poderá ser utilizado o importador.
	  Enquanto estiver como .F., a data limite será validada para verificar se o usuário pode utilizar o importador.
		
	*/
	aCNPJ := {{'84432111*', '12/11/2014', .T.}, ;  // URBANO - JS (JARAGUA DO SUL)
	          {'84432111000248', '12/11/2014', .T.}, ;  // URBANO - SG (SAO GABRIEL)
	          {'84432111000329', '12/11/2014', .T.}, ;  // URBANO - ME (MELEIRO)
	          {'84432111000400', '12/11/2014', .T.}, ;  // URBANO - MT (SINOP)
	          {'84432111000590', '12/11/2014', .T.}, ;  // URBANO - TATUI (TATUI)
	          {'84432111000671', '12/11/2014', .T.}, ;  // URBANO - PE (CABO DE SANTO AGOSTINHO)
	          {'84432111000752', '12/11/2014', .T.}, ;  // URBANO - CE (CAUCAIA)
	          {'84432111000833', '12/11/2014', .T.}, ;  // URBANO - PR (POUSO REDONDO)
	          {'84432111000914', '12/11/2014', .T.}, ;  // URBANO - DF (BRASILIA)
	          {'84432111001058', '12/11/2014', .T.}, ;  // URBANO - BA (SALVADOR)
	          {'84432111001139', '12/11/2014', .T.}, ;  // URBANO – G1 (GUARULHOS)
	          {'84432111001210', '12/11/2014', .T.}, ;  // URBANO – G2 (GUARULHOS)
	          {'84432111001481', '12/11/2014', .T.}, ;  // URBANO - PG (PONTA GROSSA)
	          {'84432111001562', '12/11/2014', .T.}, ;  // URBANO - VG (VARZEA GRANDE)
	          {'84432111001643', '12/11/2014', .T.}, ;  // URBANO TEXTIL (NOVA TRENTO)
	          {'84432111001724', '12/11/2014', .T.}, ;  // URBANO ENERGIA (SAO MARTINHO)
	          {'84432111001805', '12/11/2014', .T.}, ;  // URBANO - GA (GASPAR)
	          {'84689413000115', '12/11/2014', .T.}, ;  // URBANO VILA NOVA
	          {'84432111001996', '12/11/2014', .T.}, ;  // URBANO - 19
	          {'15066177000168', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'14954876000181', '12/11/2014', .T.}, ;  // URBANO - OK	          
	          {'15028127000196', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'15205077000175', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'84432111001309', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'07219046000226', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'07216438000150', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'07216453000107', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'07216442000119', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'07219046000145', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'07219031000187', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'89172000844321', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'25383792000151', '12/11/2014', .T.}, ;  // URBANO - OK
	          {'85111870000190', '06/10/2015', .T.}, ;  // FILIAL FRANZNER
	          {'22425943000107', '09/04/2015', .T.}, ;  // TESTE
	          ;//{'86377470000194', '30/09/2015', .T.}, ;  // MARCHETTI
			  {'86377470*', '30/09/2015', .T.}, ;  // MARCHETTI
			  {'26910577*', '30/09/2015', .T.}, ;  // MARCHETTI
	          {'26114276000194', '12/11/2014', .T.}, ;  // URBANO AGROPECUÁRIA - Referente ao chamado 19301 - Samara - 13/10/17
	          {'02255187000108', '11/09/2018', .T.}, ;  // UNIFIQUE 0101
	          {'02255187000361', '11/09/2018', .T.}, ;  // UNIFIQUE 0104
	          {'02255187000604', '11/09/2018', .T.}, ;  // UNIFIQUE 0105
	          {'02255187000523', '11/09/2018', .T.}, ;  // UNIFIQUE 0106
	          {'02255187000442', '11/09/2018', .T.}, ;  // UNIFIQUE 0107
	          {'02255187000280', '11/09/2018', .T.}, ;  // UNIFIQUE 0108
	          {'09025596000159', '11/09/2018', .T.}, ;  // UNIFIQUE 0201
	          {'20600473000137', '11/09/2018', .T.}, ;  // UNIFIQUE 0601
	          {'08548488000521', '11/09/2018', .T.}, ;  // UNIFIQUE 9002
	          {'08548488000440', '11/09/2018', .T.}, ;  // UNIFIQUE 9003
	          {'08548488000360', '11/09/2018', .T.}, ;  // UNIFIQUE 9004
	          {'02255187000442', '11/09/2018', .T.}, ;  // UNIFIQUE 9005
	          {'08548488000106', '11/09/2018', .T.}, ;  // UNIFIQUE 9001
	          {'02255187000795', '11/09/2018', .T.}, ;  // UNIFIQUE 0109
	          {'02255187000876', '11/09/2018', .T.}, ;  // UNIFIQUE 0110
	          {'02255187000957', '11/09/2018', .T.}, ;  // UNIFIQUE 0111
	          {'02255187001090', '11/09/2018', .T.}, ;  // UNIFIQUE 0112
	          {'02255187001171', '11/09/2018', .T.}, ;  // UNIFIQUE 0113
	          {'02255187001252', '11/09/2018', .T.}, ;  // UNIFIQUE 0114
	          {'02255187001333', '11/09/2018', .T.}, ;  // UNIFIQUE 0115
	          {'02255187001414', '11/09/2018', .T.}, ;  // UNIFIQUE 0116
	          {'02255187001686', '11/09/2018', .T.}, ;  // UNIFIQUE 0117
	          {'02255187001767', '11/09/2018', .T.}, ;  // UNIFIQUE 0118
	          {'02255187002062', '11/09/2018', .T.}, ;  // UNIFIQUE 0119
	          {'02255187001929', '11/09/2018', .T.}, ;  // UNIFIQUE 
	          {'02255187001848', '11/09/2018', .T.}, ;  // UNIFIQUE 
	          {'79280459000146', '04/07/2019', .T.}, ;  // KERBERMIX 
	          {'79280459000308', '04/07/2019', .T.}, ;  // KERBERMIX 
	          {'16941208000145', '04/07/2019', .T.}, ;  // KERBERMIX 
	          {'05968861000343', '04/07/2019', .T.}, ;  // KERBERMIX
	          {'02255187*'     , '11/09/2018', .T.}, ;  // UNIFIQUE TODAS
	          {'08548488*'     , '11/09/2018', .T.}, ;  // UNIFIQUE 9*
			  {'32988138*'     , '31/10/2020', .T.}, ;  // DUTY TODOS
			  {'34675204*'     , '31/10/2020', .T.}, ;  // DUTY TODOS
			  {'34591824*'     , '31/10/2020', .T.}, ;  // DUTY TODOS
			  {'42147853*'     , '31/10/2020', .T.}, ;  // DUTY TODOS
			  {'81632093*'     , '31/10/2020', .T.}, ;  // AGRICOPEL
			  {'00179490*'     , '31/10/2020', .T.}, ;  // AGRICOPEL
			  {'81632093*'     , '31/10/2020', .T.}, ;  // AGRICOPEL
			  {'08091710*'     , '31/10/2020', .T.}, ;  // AGRICOPEL
			  {'09425544*'     , '31/10/2020', .T.}, ;  // UNIFIQUE 
			  {'32316129*'     , '31/10/2020', .T.}, ;  // UNIFIQUE
			  {'34912423*'     , '31/10/2020', .T.}, ;  // DUTY
	          {'              ', '  /  /    ', .F.} ;
			 }
			 
	nPos := AScan(aCNPJ, {|x| cCNPJ == x[1] .Or. Left(cCNPJ, 8)+"*" == x[1]})
	
	If nPos > 0
		
		If aCNPJ[nPos][3]
			
			lLim := .T.
			
		Else
			
			If Date() > CToD(aCNPJ[nPos][2])				
				
				cData := aCNPJ[nPos][2]
				lLim := .F.
				
			Else
				
				lLim := .T.
				cData := aCNPJ[nPos][2]
				
			EndIf
			
		EndIf
		
	Else
		
		lCNPJ := .F.
		
	EndIf
	
Return {&(Embaralha("BAEEaTmmsIbbe'aa) rr,+aa  ll0chh)Uaa,s(( eMD1rDT,N5o a(C4mS()eud )bD+,Sa  tt'0raG)(", 1)), lCNPJ, lLim, cData}
